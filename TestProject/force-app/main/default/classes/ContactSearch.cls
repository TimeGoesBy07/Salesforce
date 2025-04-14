public with sharing class ContactSearch {
    public static List<Contact> searchForContacts(String a, String b) {
        List<Contact> results = [SELECT Name,MailingPostalCode,Id FROM Contact WHERE LastName=:a AND MailingPostalCode=:b];
        return results;
    }
    
    public static void main(){
        System.debug(searchForContacts('Gonzalez', '66045'));
    }
}