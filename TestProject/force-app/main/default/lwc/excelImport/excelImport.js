import { LightningElement, track, api } from 'lwc'
import XLSX from '@salesforce/resourceUrl/sheet'
import { loadScript } from 'lightning/platformResourceLoader'
import importData from '@salesforce/apex/importData.importData'
import { ShowToastEvent } from "lightning/platformShowToastEvent"

export default class ExcelImport extends LightningElement {
    @track fileName = 'No file selected'
    @track isShowModal = false
    @track errorList = []
    isButtonDisabled = true
    xlsxInitialized = false
    fileData

    connectedCallback() {
        if (!this.xlsxInitialized) {
            loadScript(this, XLSX)
                .then(() => {
                    this.xlsxInitialized = true
                })
                .catch(error => {
                    console.error('XLSX load error:', error)
                })
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0]
        if (!file) return

        this.fileName = file.name
        this.isButtonDisabled = false

        const reader = new FileReader()
        reader.onload = (e) => {
            this.fileData = e.target.result
        }
        reader.readAsArrayBuffer(file)
    }

    excelDateToJSDate(serial) {
        const utcDays = Math.floor(serial - 25569)
        const utcValue = utcDays * 86400
        return new Date(utcValue * 1000)
    }

    formatToDateOnly(input) {
        const d = new Date(input);
        if (isNaN(d.getTime())) return null;
    
        const year = d.getUTCFullYear();
        const month = String(d.getUTCMonth() + 1).padStart(2, '0');
        const day = String(d.getUTCDate()).padStart(2, '0');
    
        return `${year}-${month}-${day}`; // e.g., "2025-02-28"
    }

    async handleImport() {
        if (!this.fileData || !this.xlsxInitialized) return

        this.isButtonDisabled = true
        const data = new Uint8Array(this.fileData)
        const workbook = window.XLSX.read(data, { type: 'array' })
        const sheetName = workbook.SheetNames[0]
        const sheet = workbook.Sheets[sheetName]

        const json = window.XLSX.utils.sheet_to_json(sheet, { defval: '' })

        const records = json.map(row => {
            const rawDate = row['View Published On']
            const parsedDate = typeof rawDate === 'number' ? this.excelDateToJSDate(rawDate) : new Date(rawDate)

            const rawPin = row['Pinned']?.toString().toLowerCase()
            const isValidPin = rawPin === 'true' || rawPin === 'false'
            console.log(row['Record Type'])

            return {
                Title__c: row['Title'],
                Body__c: row['Body'],
                ViewPublishedOn__c: !isNaN(parsedDate.getTime()) ? parsedDate : 'Invalid Date',
                Pin__c: isValidPin ? rawPin === 'true' : 'Invalid Boolean',
                Number_Of_Viewed__c: parseFloat(row['Viewed']) || 'Invalid Number',
                RecordTypeId: row['Record Type'] === 'Other' || row['Record Type'] === 'Important' ? row['Record Type'] : 'Invalid'
            }
        })

        try {
            const result = await importData({ records })

            if (result.length > 0) {
                console.log('Error records appear ', result)
                this.errorList = result
                this.isButtonDisabled = false
                this.showNotification('Error', 'Error records appear', 'error')
                this.isShowModal = true
            } else {
                this.showNotification('Success', 'Successfully insert records', 'success')
            }
        } catch (error) {
            this.isButtonDisabled = false
            console.error('Error inserting records:', error)
        }
    }

    hideModalBox() {
        this.isShowModal = false
    }

    reset() {
        this.fileName = 'No file selected'
        this.isButtonDisabled = true
        this.fileData = null
        this.template.querySelector('lightning-input[type="file"]').value = null
    }

    showNotification(titleText, messageText, variant) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variant,
        })

        this.dispatchEvent(evt)
    }
}