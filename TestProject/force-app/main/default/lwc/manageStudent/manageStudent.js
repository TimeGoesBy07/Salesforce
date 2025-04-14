import getStudents from '@salesforce/apex/StudentController.getStudents';
import { LightningElement, wire, track, api } from 'lwc';
import STUDENT_NAME from '@salesforce/schema/Student__c.Name';
import STUDENT_CLASS from '@salesforce/schema/Student__c.Class__c';
import STUDENT_DB from '@salesforce/schema/Student__c.Date_of_Birth__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STUDENT_OBJECT from '@salesforce/schema/Student__c';
import STUDENT_MC from '@salesforce/messageChannel/studentManagement__c'
import { MessageContext, subscribe } from 'lightning/messageService';

export default class ManageStudent extends LightningElement {
    objectApiName = STUDENT_OBJECT;
    fields = [STUDENT_OBJECT, STUDENT_NAME, STUDENT_CLASS, STUDENT_DB];

    @track list = [];
    @track sizedList = [];
    @track isLoading = true;
    @track count;
    @track canDelete = true;
    @track fullCheck = false;
    @track detailRow;
    @track openCreate = false;
    @track openEdit = false;
    @track openDelete = false;
    @track singleRowDeleteId = '';
    @track deletionCheck = false;

    selectedRow;
    selectedId = '';
    subscription = null;
    searchValues = {};

    // pagination
    @track currentPage = 1;
    @track itemsPerPage = 5;
    @track totalPages = 10;
    @track selectedItems = [];
    @track singleItem = [];

    @wire(MessageContext)
    context;

    subscribeToChannel() {
        this.subscription = subscribe(this.context, STUDENT_MC, (message) => this.handleLMS(message));
    }

    handleLMS(message) {
        if (message.type === 'page-size-update') {
            this.itemsPerPage = message.noOfItems;
        }

        this.currentPage = 1;
        this.searchValues = {
            StCode: message.searchCode,
            Name: message.searchName,
            ClassName: message.searchClass,
            DateIn: message.startPoint,
            DateOut: message.endPoint
        }
        this.fetchStudents();
    }

    // @api assignParams(search){
    //     console.log(search.searchName)
    //     this.searchValues = {
    //         StCode: search.searchCode,
    //         Name: search.searchName,
    //         ClassName: search.searchClass,
    //         DateIn: search.startPoint,
    //         DateOut: search.endPoint
    //     }
    //     this.fetchStudents();
    // }

    connectedCallback() {
        this.fetchStudents();
        this.subscribeToChannel();
    }

    renderedCallback() {
        this.buttonStyle();
    }

    openDeleteModal() {
        this.openDelete = true;
    }

    openDeleteSingleModal(event) {
        this.openDelete = true;
        const row = event.target.closest('tr');
        const rowId = row.querySelector('lightning-button-icon').dataset.id;
        const selectedElement = this.list.find(element => element.Id === rowId);
        this.singleItem.push(selectedElement);
    }

    get getListToDelete() {
        return this.singleItem.length !== 0 ? this.singleItem : this.selectedItems;
    }

    openCreateForm() {
        this.openCreate = true;
    }

    openEditForm(event) {
        this.openEdit = true;
        const row = event.target.closest('tr');

        const rowData = {
            Id: row.querySelector('lightning-button-icon').dataset.id,
            Name: row.querySelector('.column-name a').textContent,
            Date_of_Birth__c: row.querySelector('.column-dob').textContent,
            Class__r: row.querySelector('.column-class a').textContent,
            Status__c: row.querySelector('.column-status').textContent,
            Total_Credit__c: row.querySelector('.column-credit').textContent,
            GPA_Score__c: row.querySelector('.column-gpa').textContent
        };

        this.selectedId = rowData.Id;
        // this.publishMessage(rowData.Id);
    }

    handleRequestCreate(event) {
        this.openCreate = event.detail.open;
        this.fetchStudents();
    }

    handleRequestUpdate(event) {
        this.openEdit = event.detail.open;
        this.fetchStudents();
    }

    handleRequestDelete(event) {
        this.singleItem = [];
        this.openDelete = event.detail.open;

        if (event.detail.checked !== '') {
            this.selectedItems = [];
            this.canDelete = true;
            this.deletionCheck = true;
            this.fetchStudents();
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this.publishMessage(row.Id);
                break;
            default:
                break;
        }
    }

    fetchStudents() {
        this.isLoading = true;

        try {
            getStudents({ wrapper: JSON.stringify(this.searchValues) })
                .then(data => {
                    let nameUrl;
                    let classUrl;
                    let classText;

                    this.list = data.map(row => {
                        nameUrl = `/${row.Id}`;
                        classUrl = `/${row.Class__c}`;
                        classText = row?.Class__r?.Name

                        return { ...row, nameUrl, classUrl, classText }
                    })

                    if (data.length === 0) {
                        this.count = 0;
                    } else {
                        this.count = data.length;
                        this.selectedItems = [];
                        this.canDelete = true;
                        this.totalPages = Math.ceil(data.length / this.itemsPerPage);
                    }

                    if (this.deletionCheck === true) {
                        this.deletionCheck = false;

                        if (this.fullCheck === true) {
                            this.fullCheck = false;
                            this.handleLastPage();
                        }
                    }

                    this.additionalFields();
                    this.isLoading = false;
                });
        } catch (error) {
            console.log('There is an error!', error.message);
            this.showToast('error', 'Error fetching data');
        }
    }

    additionalFields() {
        this.list = this.list.map(element => {
            return {
                ...element,
                isChecked: false,
                nameUrl: `/${element.Id}`,
                classUrl: `/${element.Class__c}`
            }
        })
    }

    checkAllSelect(curList) {
        this.fullCheck = true;

        for (let a = 0; a < curList.length; a++) {
            if (curList[a].isChecked === false) {
                this.fullCheck = false;
                break;
            }
        }
    }

    handleSelectAll(event) {
        this.sizedList.forEach(element => {
            element.isChecked = event.target.checked;
        })

        if (event.target.checked) {
            this.fullCheck = true;
            this.selectedItems = [...this.sizedList];
        }
        else {
            this.selectedItems = [];
        }

        this.canDelete = this.selectedItems.length > 0 ? false : true;
    }

    handleCheckboxChange(event) {
        const elementId = event.target.dataset.id;
        const selectedElement = this.sizedList.find(element => element.Id === elementId);

        if (selectedElement) {
            selectedElement.isChecked = !selectedElement.isChecked;
            console.log(selectedElement.Name, selectedElement.isChecked);

            if (selectedElement.isChecked) {
                this.selectedItems.push(selectedElement)
            }
            else {
                const index = this.selectedItems.findIndex(item => item.Id === elementId);

                if (index !== -1) {
                    this.selectedItems.splice(index, 1);
                }
            }
        }

        this.checkAllSelect(this.sizedList);
        this.canDelete = this.selectedItems.length > 0 ? false : true;
    }

    get currentPageItems() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.currentPage * this.itemsPerPage;
        this.sizedList = this.list.slice(start, end);
        return this.sizedList;
    }

    get pageNumbers() {
        const range = 2;
        let pages = [];

        if (this.currentPage >= 1) {
            pages.push(1);
        }

        if (this.currentPage - range > 2) {
            pages.push('...');
        }

        for (let i = Math.max(2, this.currentPage - range); i <= Math.min(this.totalPages - 1, this.currentPage + range); i++) {
            pages.push(i);
        }

        if (this.currentPage + range < this.totalPages - 1) {
            pages.push('...');
        }

        if (this.totalPages > 1) {
            pages.push(this.totalPages);
        }

        return pages;
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    buttonStyle() {
        const pageButtons = this.template.querySelectorAll('.num-button');

        pageButtons.forEach(button => {
            if (button.dataset.id === '...') {
                button.classList.add('dots');
                button.setAttribute('disabled', true);
                button.style.pointerEvents = 'none';
                button.style.opacity = '0.5';
            } else {
                if (parseInt(button.dataset.id) === this.currentPage) {
                    button.classList.add('active-button');
                } else {
                    button.classList.remove('active-button');
                }
            }
        });
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.buttonStyle();
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.buttonStyle();
        }
    }

    handleFirstPage() {
        this.currentPage = 1;
        this.buttonStyle();
    }

    handleLastPage() {
        this.currentPage = this.totalPages;
        this.buttonStyle();
    }

    goToPage(event) {
        const page = event.target.dataset.id;

        if (page !== '...') {
            this.currentPage = parseInt(page, 10);
            this.checkAllSelect(this.currentPageItems);
            this.buttonStyle();
        }
    }

    get checkList() {
        if (this.list.length !== 0) {
            this.buttonStyle();
            return true;
        } else {
            return false;
        }
    }

    handleSelected(event) {
        if (!this.selectedRow) {
            this.selectedRow = [];
        }

        this.selectedRow = event.detail.selectedRows;
        this.canDelete = this.selectedRow.length > 0 ? false : true;
        this.detailRow = event.detail.selectedRows[0];
    }

    showToast(typeNoti, messageNoti) {
        const noti = new ShowToastEvent({
            title: "Notification",
            variant: typeNoti,
            message: messageNoti
        })

        this.dispatchEvent(noti);
    }
}