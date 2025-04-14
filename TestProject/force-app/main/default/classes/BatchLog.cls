public with sharing class BatchLog implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name FROM Student__c WHERE Status__c = 'Active']);
    }
    
    public void execute(Database.BatchableContext bc, List<Student__c> scope){
        List<Id> listStuId = new List<Id>();
        
        for(Student__c e : scope){
            listStuId.add(e.Id);
        }
        
        List<Grade__c> gradeList = [SELECT Id,Progress_Score__c,Practical_Score__c,Midterm_Score__c,Average_Score__c,FinalTerm_Score__c,Student__c,Subject__r.Credits__c FROM Grade__c WHERE Student__c IN :listStuId ORDER BY Average_Score__c DESC NULLS LAST];
        Map<Id, Grade__c> highestGradeMap = new Map<Id, Grade__c>();
        Decimal totalWeightedScore = 0;
        Decimal totalCredit = 0;
        
        for (Grade__c grade : gradeList){
            System.debug('grade is ' + grade);

            if (!highestGradeMap.containsKey(grade.Student__c) || grade.Average_Score__c > highestGradeMap.get(grade.Subject__c).Average_Score__c){
                highestGradeMap.put(grade.Student__c, grade);
            }
        }
        
        for (Grade__c grade : highestGradeMap.values()) {
            Decimal subjectCredit = grade.Subject__r.Credits__c;
            Decimal averageScore = grade.Average_Score__c;
            totalWeightedScore += averageScore * subjectCredit;
            totalCredit += subjectCredit;
        }
        
        Decimal gpa = totalCredit > 0 ? totalWeightedScore / totalCredit : 0;
    }
    
    public void finish(Database.BatchableContext bc){
        Id jobId = bc.getJobId();  
        AsyncApexJob job = [SELECT NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        BatchLog__c batchLog = new BatchLog__c();    
        insert batchLog;
        batchLog.End_Time__c = System.now();
        
        if (job.NumberOfErrors > 0) {
            batchLog.Status__c = 'Fail'; 
            batchLog.Error_Message__c = job.ExtendedStatus; 
        } else {
            batchLog.Status__c = 'Success'; 
            batchLog.Error_Message__c = null; 
        }
        
        update batchLog;
    }
}