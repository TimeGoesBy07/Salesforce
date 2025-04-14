public with sharing class AddPrimaryContact implements Queueable{
    Contact con;
    String str;
    
    public AddPrimaryContact(Contact con, String str) {
        this.con = con;
        this.str = str;
    }
    
    public void execute(QueueableContext context) {
        // awesome code here
        List<Account> ListAccount = [select id from account where billingstate = 'NY' LIMIT 200];
        List<Contact> lstContact = new List<Contact>();
        
        for(Account acc : ListAccount){
            Contact cont = con.clone(false,false,false,false);
            cont.AccountId =  acc.id;
            lstContact.add(cont);
        }
        
        if(lstContact.size() > 0 ) insert lstContact;
    }
}