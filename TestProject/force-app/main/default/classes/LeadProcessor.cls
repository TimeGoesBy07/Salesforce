public with sharing class LeadProcessor implements Database.Batchable<sObject>{
    
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT LeadSource FROM Lead]);
    }
    
    
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        List<Lead> li = new List<Lead>();
        
        for(Lead e : scope){
            e.LeadSource = 'Dreamforce';
            li.add(e);
            recordsProcessed++;
        }
        
        update li;
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }
}