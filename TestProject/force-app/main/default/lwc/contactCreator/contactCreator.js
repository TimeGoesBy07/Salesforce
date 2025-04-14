import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTACT_LAST_NAME from '@salesforce/schema/Contact.LastName';
import CONTACT_FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';

export default class ContactCreator extends LightningElement {
    objectApiName = CONTACT_OBJECT;
    fields = [CONTACT_FIRST_NAME, CONTACT_LAST_NAME, CONTACT_EMAIL]

    // firstName = '';
    // lastName = '';
    // email = '';

    // handleFirstNameChange(event) {
    //     this.firstName = event.target.value;
    // }

    // handleLastNameChange(event) {
    //     this.lastName = event.target.value;
    // }

    // handleEmailChange(event) {
    //     this.email = event.target.value;
    // }


    // onClick(){
    //     const recordInput = {
    //         apiName: CONTACT_OBJECT.objectApiName,
    //         fields: {
    //             [CONTACT_FIRST_NAME.fieldApiName] : this.firstName,
    //             [CONTACT_LAST_NAME.fieldApiName] : this.lastName,
    //             [CONTACT_EMAIL.fieldApiName] : this.email
    //         }
    //     }

    //     createRecord(recordInput)
    //     .then((account) => console.log(account))
    // }

    handleSuccess(onSuccess) {
        const toast = new ShowToastEvent({
            title: "Account created",
            message: "Record ID: " + onSuccess.detail.id,
            variant: "success"
        })

        this.dispatchEvent(toast);
    }
}