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
private class DailyLeadProcessorTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2042';
    
    @isTest
    static void test() {
        // TO DO: implement unit test
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        List<Lead> s = new List<Lead>();
        
        for (Integer i=0; i<200; i++) {
            Lead c = new Lead(FirstName='Account', LastName='No '+i, Company='ABC');
            s.add(c);
        }
        
        insert s;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new DailyLeadProcessor());
        Test.stopTest();
    }
}