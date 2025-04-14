public with sharing class newtest {
    public boolean isRegisitionRejected{get; private set;}
    // public List<Map<String, String>> importantStMaster{get; private set;}
    
    public newtest() {
        initUsefulMasters();
    }
    
    @AuraEnabled
    public static List<Map<String, String>> initUsefulMasters(){
        List<Student__c> stMasters = [SELECT Id, Name, Class__c, Class__r.Name FROM Student__c LIMIT 10];
        List<Map<String, String>> twoParamsList = new List<Map<String, String>>();
        List<Map<String, String>> threeParamsList = new List<Map<String, String>>();
        List<String> index = new List<String>();
        index.add('isGraduated');
        
        if (stMasters.size() > 0) {
            twoParamsList = testtest.toMapList('Student__c', stMasters);
            threeParamsList = testtest.toMapList('Student__c', stMasters, index);
        }
        
        return threeParamsList;
    }
    
    @AuraEnabled
    public static List<Student__c> getStMasters(){
        List<Student__c> stMasters = [SELECT Id, Name, Class__r.Name FROM Student__c LIMIT 10];
        
        return stMasters;
    }
}