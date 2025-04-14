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

    async handleImport() {
        if (!this.fileData || !this.xlsxInitialized) return

        this.isButtonDisabled = true
        const data = new Uint8Array(this.fileData)
        const workbook = window.XLSX.read(data, { type: 'array' })
        const sheetName = workbook.SheetNames[0]
        const sheet = workbook.Sheets[sheetName]

        const json = window.XLSX.utils.sheet_to_json(sheet, { defval: '' })

        const records = json.map(row => {
            return {
                Title__c: row['Title'],
                Body__c: row['Body'],
                ViewPublishedOn__c: row['View Published On']
                    ? new Date(row['View Published On'])
                    : 'Invalid Date',
                Pin__c: row['Pinned']?.toString().toLowerCase() === 'true',
                Number_Of_Viewed__c: parseFloat(row['Viewed']) || 'Invalid Number',
                RecordTypeId: row['Record Type']
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
        });

        this.dispatchEvent(evt);
    }
}