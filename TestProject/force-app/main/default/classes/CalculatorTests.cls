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
private class CalculatorTests {

    @isTest
    static void testDivideByZero() {
        // TO DO: implement unit test
        Integer a = 5;
        Integer b = 0;
        try{
            Test.startTest();
            Decimal res = Calculator.divide(a, b);
            Test.stopTest();
        }
        catch(Calculator.CalculatorException e){
            System.assertEquals('You still can\'t divide by zero', e.getMessage());
        }
    }
}