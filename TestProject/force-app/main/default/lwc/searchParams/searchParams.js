import { LightningElement, wire, track } from 'lwc';
import STUDENT_MC from '@salesforce/messageChannel/studentManagement__c'
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SearchParams extends LightningElement {
    @track searchName = '';
    @track searchCode = '';
    @track searchClass = '';
    startPoint = '';
    endPoint = '';
    dateHasError = false;

    // pagination
    @track noOfItems = 5;
    pageOptions = [
        { label: '5', value: 5 },
        { label: '10', value: 10 },
        { label: '15', value: 15 }
    ];

    @wire(MessageContext)
    context;

    publishMessage() {
        const payload = {
            type: 'search',
            searchCode: this.searchCode,
            searchName: this.searchName,
            searchClass: this.searchClass,
            startPoint: this.startPoint,
            endPoint: this.endPoint,
            noOfItems: this.noOfItems
        };

        publish(this.context, STUDENT_MC, payload);
    
        // const childComponent = this.template.querySelector("c-manage-student");
        
        // if (childComponent) {
        //     childComponent.assignParams(payload);
        // } else {
        //     console.log('Child component not found');
        // }
    }

    publishPageSize() {
        const payload = {
            type: 'page-size-update',
            noOfItems: this.noOfItems
        };

        publish(this.context, STUDENT_MC, payload);
    }

    handlePicklistChange(event) {
        this.currentPage = 1;
        this.noOfItems = Number(event.detail.value);
        this.publishPageSize();
    }

    handleSearch() {
        this.handleValidation();

        if (this.dateHasError === false) {
            this.publishMessage();
        }
    }

    handleCodeChange(event) {
        this.searchCode = event.detail.value;
    }

    handleSearchChange(event) {
        this.searchName = event.detail.value;
    }

    handleClassChange(event) {
        this.searchClass = event.detail.value;
    }

    handleStartDate(event) {
        if (event.detail.value == null) {
            this.startPoint = '';
        } else {
            this.startPoint = event.detail.value;
        }

        console.log(event.detail.value);
    }

    handleEndDate(event) {
        if (event.detail.value == null) {
            this.endPoint = '';
        } else {
            this.endPoint = event.detail.value;
        }

        console.log(event.detail.value);
    }

    handleClear() {
        this.searchCode = '';
        this.searchClass = '';
        this.searchName = '';
        this.startPoint = ''
        this.endPoint = '';
        this.dateHasError = false;
        this.handleValidation();
        this.publishMessage();
    }

    handleValidation() {
        let startCmp = this.template.querySelector(".startPoint");
        let endCmp = this.template.querySelector(".endPoint");

        if ((this.startPoint !== '' || this.startPoint !== null) && (this.endPoint !== '' || this.endPoint !== null)) {
            const start = new Date(this.startPoint);
            const end = new Date(this.endPoint);

            if (start > end) {
                startCmp.setCustomValidity("Start date must be smaller than end date");
                endCmp.setCustomValidity("End date must be greater than start date");
                this.dateHasError = true;
                this.showToast('error', 'Invalid date range');
            } else {
                this.dateHasError = false;
                startCmp.setCustomValidity("");
                endCmp.setCustomValidity("");
            }

            startCmp.reportValidity();
            endCmp.reportValidity();
        } else {
            startCmp.setCustomValidity("");
            endCmp.setCustomValidity("");
            startCmp.reportValidity();
            endCmp.reportValidity();
        }
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