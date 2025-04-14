import { LightningElement, api, track } from 'lwc';

export default class ContactDetails extends LightningElement {
    @api selected;
    @track view = false;

    get contactEntries() {
        if (this.selected && this.view) {
            let entries = [];

            Object.keys(this.selected).forEach(key => {
                console.log(key, this.selected[key]);
                entries.push({ label: key, value: this.selected[key] });
            })

            return entries;
        }

        return [];
    }

    handleView() {
        this.view = !this.view;
    }
}