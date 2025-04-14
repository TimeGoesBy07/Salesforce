import queryAccountsByRevenue from '@salesforce/apex/AccountListControllerLwc.queryAccountsByRevenue';
import { LightningElement, wire } from 'lwc';

export default class AccountFinder extends LightningElement {
    annualRevenue = null;

    @wire(queryAccountsByRevenue, { annualRevenue: '$annualRevenue' })
    accounts;

    handleChange(event) {
        this.annualRevenue = event.detail.value;
    }

    reset() {
        this.annualRevenue = null;
    }

    get name(){
        return this.annualRevenue.name;
    }
}