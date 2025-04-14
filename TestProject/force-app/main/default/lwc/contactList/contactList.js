import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_LAST_NAME from '@salesforce/schema/Contact.LastName';
import CONTACT_FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
import CONTACT_ID from '@salesforce/schema/Contact.Id';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import deleteContacts from '@salesforce/apex/ContactController.deleteContacts';

const columns = [
    { label: 'Id', type: 'text', fieldName: CONTACT_ID.fieldApiName },
    { label: 'First Name', type: 'text', fieldName: CONTACT_FIRST_NAME.fieldApiName },
    { label: 'Last Name', type: 'text', fieldName: CONTACT_LAST_NAME.fieldApiName },
    { label: 'Email', type: 'text', fieldName: CONTACT_EMAIL.fieldApiName }
]

export default class ContactList extends LightningElement {
    name = '';
    columns = columns;
    selectedRow;
    @track contacts;
    @track hasData;
    @track count;
    @track canDelete = true;
    @track detailRow;

    @wire(getContacts, { name: '$name' })
    wiredContacts({ data, error }) {
        if (data) {
            this.contacts = data;

            if (data.length === 0) {
                this.hasData = false;
                this.count = 0;
            }
            else {
                this.hasData = true;
                this.count = data.length;
            }
        }
        else {
            console.log('Error getting data', error);
            this.hasData = false;
        }
    }

    handleNameChange(event) {
        this.name = event.detail.value;
    }

    get countResults() {
        return this.count;
    }

    handleRefresh() {
        window.location.reload();
    }

    handleSelected(event) {
        if (!this.selectedRow) {
            this.selectedRow = [];
        }

        this.selectedRow = event.detail.selectedRows;
        this.canDelete = this.selectedRow.length > 0 ? false : true;
        this.detailRow = event.detail.selectedRows[0];
    }

    handleDelete() {
        if (this.selectedRow.length > 0) {
            deleteContacts({ ct: JSON.stringify(this.selectedRow) })
                .then(() => {
                    const noti = new ShowToastEvent({
                        title: "Notification",
                        variant: "success",
                        message: "Deleted successfully!"
                    })

                    this.dispatchEvent(noti);
                })
                .catch((error) => {
                    console.error('Error deleting contacts', error);
                });
        } else {
            console.log('No rows selected to delete');
        }
    }

    handleFinding() {
        const count = this.contacts.data ? this.contacts.length : 0;

        const noti = new ShowToastEvent({
            title: "Notification",
            variant: count > 0 ? "success" : "fail",
            message: "Found " + this.contacts.length + " results"
        })

        this.dispatchEvent(noti);
    }
}