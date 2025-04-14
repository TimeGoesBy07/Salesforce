import { LightningElement, api, track } from 'lwc';
import STUDENT_OBJECT from '@salesforce/schema/Student__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSingleStudent from '@salesforce/apex/StudentController.getSingleStudent';
import getClasses from '@salesforce/apex/StudentController.getClasses';
import updateStudent from '@salesforce/apex/StudentController.updateStudent';

export default class StudentDetails extends LightningElement {
    objectApiName = STUDENT_OBJECT;
    @api studentid;
    @api open = false;
    @track isDisabled = false;
    @track isShown = true;
    @track timeVariable = 0;
    @track studentInfo;
    @track classesInfo = [];
    @track isLoading = true;
    timeId;
    intervalId;
    newName;
    newDob;
    newGPA;
    newCredits;
    newStatus = '';
    newClass = '';

    handleNameChange(event) {
        this.newName = event.detail.value;
    }

    handleDobChange(event) {
        this.newDob = event.detail.value;
    }

    handleStatusChange(event) {
        this.newStatus = event.detail.value;
    }

    handleGPAChange(event) {
        this.newGPA = event.detail.value;
    }

    handleCreditsChange(event) {
        this.newCredits = event.detail.value;
    }

    handleClassChange(event) {
        this.newClass = event.detail.recordId;
    }

    setShow() {
        this.isShown = true;
    }

    validAge() {
        const birthDate = new Date(this.newDob);
        const currentDate = new Date();
        let age = currentDate.getFullYear() - birthDate.getFullYear();
        const monthDifference = currentDate.getMonth() - birthDate.getMonth();

        if (monthDifference < 0 || (monthDifference === 0 && currentDate.getDate() < birthDate.getDate())) {
            age--;
        }

        return age >= 18;
    }

    showToast(typeNoti, messageNoti) {
        const noti = new ShowToastEvent({
            title: "Notification",
            variant: typeNoti,
            message: messageNoti
        })

        this.dispatchEvent(noti);
    }

    getStudent() {
        this.isLoading = true;

        getSingleStudent({ stId: this.studentid }).then(response => {
            this.studentInfo = response;
            this.newName = this.studentInfo.Name;
            this.newDob = this.studentInfo.Date_of_Birth__c;
            this.newClass = this.studentInfo.Class__r.Id;
            Object.assign(this.studentInfo, { className: this.studentInfo.Class__r.Name });
            this.getClassList();
            this.isLoading = false;
        })
    }

    getClassList() {
        getClasses().then(response => {
            this.classesInfo = response;
        })
    }

    connectedCallback() {
        this.getStudent();

        this.timeId = setTimeout(() => {
            this.showToast('warning', 'Your time for editing has run out!');
            this.closeModal();
        }, 1000 * 30);

        this.intervalId = setInterval(() => {
            this.timeVariable++;
        }, 1000)
    }

    closeModal() {
        if (this.timeId) {
            clearTimeout(this.timeId);
        }

        if (this.intervalId) {
            this.timeVariable = 0;
            clearInterval(this.intervalId);
        }

        const requestClose = new CustomEvent('message', {
            detail: { open: false }
        });

        this.dispatchEvent(requestClose);
        this.open = false;
    }

    handleUpdate() {
        this.isDisabled = true;
        this.isLoading = true;

        if (this.validAge()) {
            let updateChanges = {
                StId: this.studentInfo.Id,
                Name: this.newName,
                ClassName: this.newClass,
                Birthday: this.newDob,
                Status: this.newStatus,
                Score: this.newGPA,
                Credits: this.newCredits
            };

            updateStudent({ wrapper: JSON.stringify(updateChanges) })
                .then(() => {
                    this.showToast('success', 'Update successfully!');
                    this.isLoading = false;
                    this.closeModal();
                })
                .catch((error) => {
                    console.log(error.body.fieldErrors.Name[0].statusCode);
                    this.showToast('error', error.body.fieldErrors.Name[0].statusCode);
                    this.isLoading = false;
                    this.isDisabled = false;
                })
        } else {
            this.isLoading = false;
            this.isDisabled = false;
            this.showToast('error', 'Invalid Date of Birth!');
        }
    }

    handleSuccess() {
        this.closeModal();

        const noti = new ShowToastEvent({
            title: "Notification",
            variant: "success",
            message: "Updated successfully!"
        })

        this.dispatchEvent(noti);
    }
}