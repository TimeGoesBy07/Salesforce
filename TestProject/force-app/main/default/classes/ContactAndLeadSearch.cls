public with sharing class ContactAndLeadSearch {
    public static List<List<sObject>> searchContactsAndLeads(String par) {
        // List<List<sObject>> results = [FIND :par IN NAME FIELDS RETURNING Account(Name WHERE LastName=:par OR FirstName=:par), Lead(Name WHERE LastName=:par OR FirstName=:par)];
        List<List<sObject>> results = [FIND :par IN NAME FIELDS RETURNING Contact(Name), Lead(FirstName,LastName)];
        return results;
    }

    public static void main(){
        System.debug(searchContactsAndLeads('Smith'));
    }
}