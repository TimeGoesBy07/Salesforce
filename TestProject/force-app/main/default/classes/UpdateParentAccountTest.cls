@isTest
private class UpdateParentAccountTest {
    @isTest
    static void UpdateParentAccountTest() {
        List<Account> accList = [SELECT Id FROM Account WHERE BillingState='NY'];
        Id parentId = [SELECT Id FROM Account WHERE Name='1304'][0].id;

        Test.startTest();
        UpdateParentAccount a = new UpdateParentAccount(accList, parentId);
        System.enqueueJob(a);
        Test.stopTest();
    }
}