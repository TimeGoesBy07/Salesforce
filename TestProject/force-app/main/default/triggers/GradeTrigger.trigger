trigger GradeTrigger on Grade__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) GradeTriggerHandler.onInsert(Trigger.new);
        
        if (Trigger.isUpdate) GradeTriggerHandler.onUpdate(Trigger.new, Trigger.oldMap);
    }
}