public with sharing class StudentController {
    public class StudentWrapper
    {
        @auraenabled
        public String StId{get;set;}
        @auraenabled
        public String StCode{get;set;}
        @auraenabled
        public String Name{get;set;}
        @auraenabled
        public String ClassName{get;set;}
        @auraenabled
        public String DateIn{get;set;}
        @auraenabled
        public String DateOut{get;set;}
    }
    
    public class StudentChangesWrapper
    {
        @auraenabled
        public String StId{get;set;}
        @auraenabled
        public String Name{get;set;}
        @auraenabled
        public String ClassName{get;set;}
        @auraenabled
        public String Birthday{get;set;}
        @auraenabled
        public String Status{get;set;}
        @auraenabled
        public String Score{get;set;}
        @auraenabled
        public String Credits{get;set;}
    }
    
    @AuraEnabled
    public static List<Student__c> getStudents(String wrapper) {
        StudentWrapper studentObject = (StudentWrapper)JSON.deserialize(wrapper, StudentWrapper.class);
        List<String> conditions = new List<String>();
        
        String baseQuery = 'SELECT Id'
            + ', Name'
            + ', Student_Code__c'
            + ', Date_of_Birth__c'
            + ', Class__c'
            + ', GPA_Score__c'
            + ', Status__c'
            + ', Total_Credit__c'
            + ', Class__r.Name '
            + 'FROM Student__c';
        
        if (String.isNotBlank(studentObject.Name)) {
            String likeValue = '\'%' + String.escapeSingleQuotes(studentObject.Name) + '%\'';
            conditions.add('Name LIKE ' + likeValue);
        }
        
        if (String.isNotBlank(studentObject.StCode)) {
            String likeValue = '\'%' + String.escapeSingleQuotes(studentObject.StCode) + '%\'';
            conditions.add('Student_Code__c LIKE ' + likeValue);
        }
        
        if (String.isNotBlank(studentObject.ClassName)) {
            String likeValue = '\'%' + String.escapeSingleQuotes(studentObject.ClassName) + '%\'';
            conditions.add('Class__r.Name LIKE ' + likeValue);
        }
        
        if (String.isNotBlank(studentObject.DateIn)) {
            Date startInput = Date.valueOf(studentObject.DateIn);
            conditions.add('Date_of_Birth__c >= :startInput');
        }
        
        if (String.isNotBlank(studentObject.DateOut)) {
            Date endInput = Date.valueOf(studentObject.DateOut);
            conditions.add('Date_of_Birth__c <= :endInput');
        }
        
        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        List<Student__c> lstStudent = Database.query(baseQuery);
        System.debug(lstStudent);
        return lstStudent;
    }
    
    @AuraEnabled
    public static Student__c getSingleStudent(String stId){
        return [SELECT Id
        , Name
        , Date_of_Birth__c
        , Class__c
        , GPA_Score__c
        , Status__c
        , Total_Credit__c
        , Class__r.Name 
        FROM Student__c WHERE Id=:stId WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static void updateStudent(String wrapper){
        StudentChangesWrapper studentObject = (StudentChangesWrapper)JSON.deserialize(wrapper, StudentChangesWrapper.class);
        
        Student__c newInfo = new Student__c();
        newInfo.Id = studentObject.StId;
        
        if(String.isNotBlank(studentObject.Name)){
            newInfo.Name = studentObject.Name;
        }
        
        if(String.isNotBlank(studentObject.Birthday)){
            newInfo.Date_of_Birth__c = Date.valueOf(studentObject.Birthday);
        }
        
        if(String.isNotBlank(studentObject.ClassName)){
            Class__c classRecord = [SELECT Id FROM Class__c WHERE Id = :studentObject.ClassName LIMIT 1];
            newInfo.Class__c = classRecord.Id;
        }
        
        if(String.isNotBlank(studentObject.Score)){
            newInfo.GPA_Score__c = Decimal.valueOf(studentObject.Score);
        } else {
            newInfo.GPA_Score__c = null;
        }
        
        if(String.isNotBlank(studentObject.Status)){
            newInfo.Status__c = studentObject.Status;
        } else {
            newInfo.Status__c = null;
        }
        
        if(String.isNotBlank(studentObject.Credits)){
            newInfo.Total_Credit__c = Decimal.valueOf(studentObject.Credits);
        } else {
            newInfo.Total_Credit__c = null;
        }
        
        update newInfo;
    }
    
    @AuraEnabled
    public static List<Class__c> getClasses(){
        return [SELECT Id, Name FROM Class__c WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static void deleteStudents(List<String> ct){
        List<Student__c> studentsList = [SELECT Id, Name FROM Student__c WHERE Id IN :ct WITH SECURITY_ENFORCED];
        System.debug('studentsList is '+ studentsList);
        
        if (!studentsList.isEmpty()) {
            delete studentsList;
        }
    }
}