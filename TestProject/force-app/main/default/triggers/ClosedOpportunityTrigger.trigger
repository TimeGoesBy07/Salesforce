trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Opportunity> li = [SELECT Id,StageName FROM Opportunity WHERE Id IN :Trigger.new];
    List<Task> toUpdate = new List<Task>();
    
    for(Opportunity opp : li){
        if(opp.StageName == 'Closed Won'){
            Task temp = new Task(Subject = 'Follow Up Test Task', WhatId = opp.Id);
            toUpdate.add(temp);
        }
    }
    
    insert toUpdate;
}