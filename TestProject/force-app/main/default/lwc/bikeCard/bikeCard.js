import { LightningElement, track } from 'lwc';
import testmap from '@salesforce/apex/newtest.initUsefulMasters';
import testlist from '@salesforce/apex/newtest.getStMasters';

export default class BikeCard extends LightningElement {
    name = 'Electra X4';
    description = 'A sweet bike built for comfort.';
    category = 'Mountain';
    material = 'Steel';
    price = '$2,700';
    pictureUrl = 'https://s3-us-west-1.amazonaws.com/sfdc-demo/ebikes/electrax4.jpg';

    @track list = null
    @track anotherlist = null
    
    renderedCallback(){
        testmap().then(result => {
            this.list = result;
            console.log(result);
        });

        testlist().then(result => {
            this.anotherlist = result;
            console.log(result);
        });
    }
}