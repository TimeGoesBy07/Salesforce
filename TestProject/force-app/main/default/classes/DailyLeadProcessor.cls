public with sharing class DailyLeadProcessor implements Schedulable {
    public void execute(SchedulableContext ctx) {
        // awesome code here
        List<Lead> li = [SELECT Id, Name FROM Lead WHERE LeadSource='' limit 200];
        List<Lead> toUpdate = new List<Lead>();
        
        for(Lead e : li){
            Lead a = new Lead(Id=e.Id,LeadSource='Dreamforce');
            toUpdate.add(a);
        }
        
        update toUpdate;
    }
}