@isTest
public with sharing class BatchTest {
    
    @isTest
    static void testTheBatch() {
        // TO DO: implement unit test
        Class__c classRecord = new Class__c(Name = 'Math 101');
        insert classRecord;
        
        Student__c student = new Student__c(Name = 'Test Student',Status__c = 'Active',Class__c = classRecord.Id,Date_of_Birth__c = Date.newInstance(2000, 11, 26));
        insert student;
        
        Subject__c subject = new Subject__c(Name = 'Math 101',Credits__c = 3,Subject_Type__c='General Subject');
        insert subject;
        
        Grade__c grade = new Grade__c(
            Name='HK2',
        Student__c = student.Id,
        Subject__c = subject.Id,
        Progress_Score__c = 8.5,
        Practical_Score__c = 8.8,
        Midterm_Score__c = 9,
        Average_Score__c = 7.9,
        FinalTerm_Score__c = 9.4
            );
        insert grade;
        
        Test.startTest();
        BatchLog batch = new BatchLog();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
    
}