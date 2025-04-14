/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AddPrimaryContactTest {
    @isTest
    static void test() {
        // TO DO: implement unit test
        List<Account> accounts = new List<Account>();
        // add 100 child accounts
        for (Integer i = 0; i < 50; i++)
            accounts.add(new Account(name='Test Account'+i, BillingState='NY'));
        
        for (Integer j = 0; j < 50; j++)
            accounts.add(new Account(name='Test Account'+j, BillingState='CA'));
        
        insert accounts;

        Contact co = new Contact(FirstName='demo',LastName='demo');
        insert co;
        String state = 'CA';
        
        Test.startTest();
        AddPrimaryContact z = new AddPrimaryContact(co,state);
        System.enqueueJob(z);
        Test.stopTest();
    }
}