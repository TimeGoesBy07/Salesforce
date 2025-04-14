import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bt';
import logo from '@salesforce/resourceUrl/image';

export default class Mobile extends LightningElement {
    static renderMode = 'light'; // Dùng Light DOM để jQuery hoạt động tốt hơn
    @api imgUrl = logo + '/pasona-seeklogo.png';
   
    jQueryLoaded = false;
 
    renderedCallback() {
        if (this.jQueryLoaded) {
            return;
        }
 
        Promise.all([
            loadScript(this, bootstrap + '/css/js/jquery.min.js')
        ])
        .then(() => {
            return loadScript(this, bootstrap + '/css/js/bootstrap.min.js');
        })
        .then(() => {
            return Promise.all([
                loadStyle(this, bootstrap + '/css/css/bootstrap.min.css'),
                loadStyle(this, bootstrap + '/css/css/bootstrap-theme.min.css')
            ]);
        })
        .then(() => {
            this.jQueryLoaded = true;
            console.log("Bootstrap and jQuery have been loaded successfully.");
 
            // Áp dụng jQuery sau khi đã load
            this.applyJQuery();
        })
        .catch(error => {
            console.error("Failed to load Bootstrap and jQuery:", error);
        });
    }
 
    applyJQuery() {
        if (window.jQuery) {
            console.log("jQuery is ready to use!");
 
            // Chọn phần tử trong component và áp dụng jQuery
            window.jQuery('.header-title').css('color', 'red'); // Đổi màu chữ thành đỏ
        } else {
            console.error("jQuery is not available.");
        }
    }
}