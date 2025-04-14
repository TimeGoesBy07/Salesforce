public with sharing class ContactController {
    public class StudentWrapper
    {
        @auraenabled
        public String StId{get;set;}
        @auraenabled
        public String Name{get;set;}
        @auraenabled
        public String ClassName{get;set;}
        @auraenabled
        public String DateIn{get;set;}
        @auraenabled
        public String DateOut{get;set;}
    }
    
    @AuraEnabled
    public static List<Student__c> getStudents(String wrapper) {
        StudentWrapper studentObject = (StudentWrapper)JSON.deserialize(wrapper, StudentWrapper.class);
        String baseQuery = 'SELECT Id, Name, Date_of_Birth__c, Class__c, GPA_Score__c, Status__c, Total_Credit__c, Class__r.Name FROM Student__c';
        String lastQuery = ' WITH SECURITY_ENFORCED';
        String resultQuery = baseQuery;
        Boolean whereAdded = false;
        
        if (String.isNotBlank(studentObject.Name)) {
            String likeValue = '%' + studentObject.Name + '%';
            
            if (whereAdded) {
                resultQuery += ' AND Name LIKE :likeValue';
            } else {
                resultQuery += ' WHERE Name LIKE :likeValue';
                whereAdded = true;
            }
        }
        
        if (String.isNotBlank(studentObject.StId)) {
            String studentId = studentObject.StId;
            
            if (whereAdded) {
                resultQuery += ' AND Id = :studentId';
            } else {
                resultQuery += ' WHERE Id = :studentId';
                whereAdded = true;
            }
        }
        
        if (String.isNotBlank(studentObject.ClassName)) {
            String className = studentObject.ClassName;
            
            if (whereAdded) {
                resultQuery += ' AND Class__r.Name = :className';
            } else {
                resultQuery += ' WHERE Class__r.Name = :className';
                whereAdded = true;
            }
        }
        
        if (String.isNotBlank(studentObject.DateIn) && String.isNotBlank(studentObject.DateOut)) {
            Date startInput = Date.valueOf(studentObject.DateIn);
            Date endInput = Date.valueOf(studentObject.DateOut);
            
            if (whereAdded) {
                resultQuery += ' AND Date_of_Birth__c >= :startInput AND Date_of_Birth__c <= :endInput';
            } else {
                resultQuery += ' WHERE Date_of_Birth__c >= :startInput AND Date_of_Birth__c <= :endInput';
                whereAdded = true;
            }
        }
        
        resultQuery += lastQuery;
        
        return Database.query(resultQuery);
    }
    
    @AuraEnabled
    public static void deleteStudents(String ct){
        List<Student__c> studentsList = (List<Student__c>)JSON.deserialize(ct, List<Student__c>.class);
        
        try {
            System.debug ('list is: ' + studentsList);
            delete studentsList;
        } catch (Exception e) {
            System.debug ('list is: ' + studentsList);
            System.debug ('Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String name) {
        if(name == ''){
            return [SELECT Id, FirstName, LastName, Email FROM Contact WITH SECURITY_ENFORCED ];
        } else {
            return [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName=:name OR FirstName=:name WITH SECURITY_ENFORCED ];
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccounts(String name) {
        if(name == ''){
            return [SELECT Id, FirstName, LastName, Email FROM Contact WITH SECURITY_ENFORCED ];
        } else {
            return [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName=:name OR FirstName=:name WITH SECURITY_ENFORCED ];
        }
    }
    
    @AuraEnabled
    public static void deleteContacts(String ct){
        List<Contact> studentsList = (List<Contact>)JSON.deserialize(ct, List<Contact>.class);
        
        try {
            System.debug ('list is: ' + studentsList);
            delete studentsList;
        } catch (Exception e) {
            System.debug ('list is: ' + studentsList);
            System.debug ('Error: ' + e.getMessage());
        }
    }
}