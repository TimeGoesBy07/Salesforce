import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STUDENT_OBJECT from '@salesforce/schema/Student__c';

export default class CreateStudent extends LightningElement {
    objectApiName = STUDENT_OBJECT;
    @api open = false;
    @track disableTrigger = false;
    error;

    handleNewStudent(event) {
        console.log('onsubmit event recordEditForm' + event.detail.fields);
    }

    closeModal() {
        const requestClose = new CustomEvent('message', {
            detail: { open: false }
        });

        this.dispatchEvent(requestClose);
        this.open = false;
    }

    handleButtonClick() {
        this.disableTrigger = true;
        const form = this.template.querySelector('lightning-record-edit-form');
        form.submit();
    }

    handleSuccess(onSuccess) {
        this.closeModal();
        this.showToast('success', 'New student created! Record ID: ' + onSuccess.detail.id);
    }

    handleError(onError) {
        this.disableTrigger = false;
        this.error = onError.detail;
        console.log(JSON.stringify(this.error));
        this.showToast('error', onError.detail.detail);
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