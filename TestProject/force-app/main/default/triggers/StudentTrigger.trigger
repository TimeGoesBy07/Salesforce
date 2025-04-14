trigger StudentTrigger on Student__c (before insert, before delete, after insert, after delete, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            StudentTriggerHandler.onBeforeInsert(Trigger.new);
        
        if(Trigger.isDelete)
            StudentTriggerHandler.onBeforeDelete(Trigger.oldMap);
    }
    if (Trigger.isAfter) {
        if(Trigger.isInsert)
            StudentTriggerHandler.onAfterInsert(Trigger.newMap);
        
        if(Trigger.isDelete)
            StudentTriggerHandler.onAfterDelete(Trigger.oldMap);
        
        if (Trigger.isUpdate)
            StudentTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        
    }
}