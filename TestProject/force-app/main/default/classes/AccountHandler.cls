public with sharing class AccountHandler {
    public static Account insertNewAccount(String name) {
        try{
            Account acc = new Account(Name = name);
            insert acc;
            return acc;
        }
        catch(DmlException e){
            System.debug(e);
            return null;
        }
    }

    public static void main(){
        System.debug('First account: ' + insertNewAccount('Abc'));
        System.debug('Second account: ' + insertNewAccount(''));
    }
}