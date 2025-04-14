public with sharing class AccountProcessor {
    @future
    public static void countContacts(List<Id> recordIds) {
        // The method must accept a List of Account IDs
        // The method must use the @future annotation
        // The method counts the number of Contact records
        // associated to each Account ID passed to the method and
        // updates the 'Number_Of_Contacts__c' field with this value
        List<Account> toUpdate = new List<Account>();
                
        for(Id e  : recordIds){
            Integer noOfContacts = [SELECT COUNT() FROM Contact WHERE Id=:e];
            Account a = new Account(Id=e,Number_Of_Contacts__c = noOfContacts);
            toUpdate.add(a);
        }

        update toUpdate;
    }
}