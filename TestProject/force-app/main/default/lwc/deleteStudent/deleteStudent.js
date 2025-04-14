import { LightningElement, api, track } from 'lwc';
import deleteStudents from '@salesforce/apex/StudentController.deleteStudents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeleteStudent extends LightningElement {
    @api studentlist;
    @api open = false;
    @track disableTrigger = false;
    @track isLoading = true;
    @track selectAll = '';

    columns = [
        {
            label: 'Id', type: 'text', fieldName: 'Id'
        },
        {
            label: 'Name', type: 'text', fieldName: 'Name'
        }
    ]

    closeModal() {
        const requestClose = new CustomEvent('message', {
            detail: { open: false, checked: this.selectAll }
        });

        this.dispatchEvent(requestClose);
        this.open = false;
    }

    handleDelete() {
        this.disableTrigger = true;
        this.isLoading = true;

        if (this.studentlist.length > 0) {
            const listId = this.studentlist.map(element => element.Id);

            deleteStudents({ ct: listId })
                .then(() => {
                    this.showToast('success', 'Deleted successfully!');
                    this.isLoading = false;
                    this.selectAll = 'deletion';
                    this.closeModal();
                })
                .catch(() => {
                    this.showToast('error', 'Error deleting contacts');
                    this.isLoading = false;
                });
        } else {
            console.log('No rows selected to delete');
            this.showToast('error', 'No row was selected to be deleted');
            this.isLoading = false;
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