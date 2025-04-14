public with sharing class StudentTriggerHandler {
    private static Boolean checkAge(Date today, Date dateOfBirth){
        if(dateOfBirth == null){
            System.debug('Date of birth is null');
            return false;
        }else{
            if(today.year() - dateOfBirth.year() < 18){
                return false;
            }
            
            return true;
        }
    }
    
    private static void afterChange(Map<Id, Student__c> studentMap, String typeOfChange){
        if(typeOfChange == 'Update'){
            
        }
        else{
            Set<Id> classIdsToUpdate = new Set<Id>();
            
            for (Student__c student : studentMap.values()) {
                if (student.Class__c != null) {
                    classIdsToUpdate.add(student.Class__c);
                }
            }
            
            List<Class__c> classList = [SELECT Id FROM Class__c WHERE Id IN :classIdsToUpdate];
            List<AggregateResult> studentCount = [SELECT COUNT(Id),Class__c FROM Student__c WHERE Class__c IN :classList GROUP BY Class__c];
            Map<Id, Integer> mappingCountWithClass = new Map<Id, Integer>();
            List<Class__c> classesToUpdate = new List<Class__c>();
            
            for(AggregateResult element : studentCount){
                Id classId = (Id) element.get('Class__c');
                Integer count = (Integer) element.get('expr0');
                mappingCountWithClass.put(classId,count);
            }
            
            for (Class__c element : classList) {
                if (mappingCountWithClass.containsKey(element.Id)) {
                    element.Number_of_Student__c = mappingCountWithClass.get(element.Id);
                    classesToUpdate.add(element);
                }
            }
            
            if (!classesToUpdate.isEmpty()){
                update classesToUpdate;
            }
        }
    }
    
    // add students
    public static void onBeforeInsert(List<Student__c> studentsList) {
        if(studentsList == null){
            System.debug('The list is null');
            return;
        }
        
        for(Student__c st : studentsList){
            if(!checkAge(Date.today(), st.Date_of_Birth__c)){
                st.addError('Student must be 18 years or older.');
            }
        }
    }
    
    public static void onAfterInsert(Map<Id, Student__c> studentMapNew){
        // Set<Id> newStudent = studentMapNew.keySet(); // list of new students
        // List<Class__c> classList = [SELECT Id FROM Class__c WHERE Id IN (SELECT Class__c FROM Student__c WHERE Id IN :newStudent)];
        // List<AggregateResult> studentCount = [SELECT COUNT(Id),Class__c FROM Student__c WHERE Class__c IN :classList GROUP BY Class__c];
        // Map<Id, Integer> mappingCountWithClass = new Map<Id, Integer>(); // map classes' ID with the count amount
        // List<Class__c> classesToUpdate = new List<Class__c>(); // list of update classes
        
        // for(AggregateResult element : studentCount){ // map classes' ID with the count amount
            //     Id classId = (Id) element.get('Class__c');
            //     Integer count = (Integer) element.get('expr0');
            //     mappingCountWithClass.put(classId,count);
        // }
        
        // for (Class__c element : classList) { // convert the map into list
            //     if (mappingCountWithClass.containsKey(element.Id)) { // ensure the Id of map's values exists
                //         element.Number_of_Student__c = mappingCountWithClass.get(element.Id); // get the value the Id
                //         classesToUpdate.add(element);
            //     }
        // }
        
        // if (!classesToUpdate.isEmpty()){
            //     update classesToUpdate;
        // }
        afterChange(studentMapNew, 'After insert');
    }
    
    // delete students
    public static void onBeforeDelete(Map<Id, Student__c> studentMapOld){
        Set<Id> deleteStudent = studentMapOld.keySet();
        List<Grade__c> gradeListDelete = [SELECT Id FROM Grade__c WHERE Student__c IN :deleteStudent];
        
        if(!gradeListDelete.isEmpty()) {
            delete gradeListDelete;
        }
    }
    
    public static void onAfterDelete(Map<Id, Student__c> studentMapOld){
        // Set<Id> deleteStudent = studentMapOld.keySet(); // list of students' ID
        // Set<Id> classIdsToUpdate = new Set<Id>();
        
        // for (Student__c student : studentMapOld.values()) {
            //     if (student.Class__c != null) {
                //         classIdsToUpdate.add(student.Class__c);
            //     }
        // }
        
        // List<Class__c> classList = [SELECT Id FROM Class__c WHERE Id IN :classIdsToUpdate]; // get classes list needed to be updated
        // List<AggregateResult> studentCount = [SELECT COUNT(Id),Class__c FROM Student__c WHERE Class__c IN :classList GROUP BY Class__c];
        // Map<Id, Integer> mappingCountWithClass = new Map<Id, Integer>(); // map classes' ID with the count amount
        // List<Class__c> classesToUpdate = new List<Class__c>(); // list of update classes
        
        // for(AggregateResult element : studentCount){ // map classes' ID with the count amount
            //     Id classId = (Id) element.get('Class__c');
            //     Integer count = (Integer) element.get('expr0');
            //     mappingCountWithClass.put(classId,count);
        // }
        
        // for (Class__c element : classList) { // convert the map into list
            //     if (mappingCountWithClass.containsKey(element.Id)) { // ensure the Id of map's values exists
                //         element.Number_of_Student__c = mappingCountWithClass.get(element.Id); // get the value the Id
                //         classesToUpdate.add(element);
            //     }
        // }
        
        // if (!classesToUpdate.isEmpty()){
            //     update classesToUpdate;
        // }
        afterChange(studentMapOld, 'After delete');
    }
    
    // update sudents
    public static void onAfterUpdate(Map<Id, Student__c> studentMapNew, Map<Id, Student__c> studentMapOld){
        Set<Id> classList = new Set<Id>();
        Map<Id, Integer> mappingCountWithClass = new Map<Id, Integer>();
        
        for (Id id : studentMapNew.keySet()) {
            if(studentMapNew.get(id).Class__c != studentMapOld.get(id).Class__c){
                if(studentMapOld.get(id).Class__c != null){
                    classList.add(studentMapOld.get(id).Class__c);
                }
                
                if(studentMapNew.get(id).Class__c != null){
                    classList.add(studentMapNew.get(id).Class__c);
                }
            }
        }
        
        List<AggregateResult> studentCount = [SELECT COUNT(Id),Class__c FROM Student__c WHERE Class__c IN :classList GROUP BY Class__c];
        List<Class__c> idOfNeededClasses = [SELECT Id, Number_of_Student__c FROM Class__c WHERE Id IN :classList];
        List<Class__c> classesToUpdate = new List<Class__c>();
        
        for(AggregateResult element : studentCount){
            Id classId = (Id) element.get('Class__c');
            Integer count = (Integer) element.get('expr0');
            mappingCountWithClass.put(classId,count);
        }
        
        for (Class__c element : idOfNeededClasses) {
            if (mappingCountWithClass.containsKey(element.Id)) {
                element.Number_of_Student__c = mappingCountWithClass.get(element.Id);
                classesToUpdate.add(element);
            }
        }
        
        if (!classesToUpdate.isEmpty()){
            update classesToUpdate;
        }
    }
}