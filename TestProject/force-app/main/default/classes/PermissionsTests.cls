@IsTest
private class PermissionsTests {
    @TestSetup
    static void testSetup() {
        User testUser = TestFactory.generateUser('Standard User');
        insert testUser;

        // Query the Private_Object_Access permission set
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Private_Object_Access'];

        if (permSet != null) {
            // Create a new Permission Set Assignment
            insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = permSet.Id);
        } else {
            System.assert(false, 'Private_Object_Access permission set not found.');
        }
    }
    
    @IsTest
    static void testNegativePermissionSet() {
        // GIVEN
        User userNew = TestFactory.generateUser('Standard User');
        System.runAs(userNew) {
            // WHEN
            Test.startTest();
            Private_Object__c[] privateObj = [SELECT Id, Account__c, Notes__c FROM Private_Object__c];
            Test.stopTest();
            // THEN
            Assert.areEqual(
                0,
            privateObj.size(),
            'A user without the permission set shouldn\'t see any records');
        }
    }
    
    @isTest
    static void testPositivePermissionSet() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest(); // Start the test context
            // Create a Private_Object__c record
            Private_Object__c privateObject = new Private_Object__c();
            insert privateObject;
            
            // Query Private_Object__c records
            List<Private_Object__c> queriedObjects = [SELECT Id FROM Private_Object__c];
            
            // Check if the queriedObjects list contains the privateObject record
            System.assertEquals(1, queriedObjects.size(), 'User with Private_Object_Access permission set cannot view Private_Object__c records they do not own.');
            System.assertEquals(privateObject.Id, queriedObjects[0].Id, 'User with Private_Object_Access permission set cannot view specific Private_Object__c record they do not own.');
            Test.stopTest(); // Stop the test context
        }
    }
}