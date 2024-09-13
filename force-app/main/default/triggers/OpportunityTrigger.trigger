trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete) {

  /*  switch on Trigger.operationType {
        when AFTER_INSERT {

            OpportunityTriggerHandler.createFoloupTaskandField(trigger.new, null);
        }
         when AFTER_UPDATE {
            OpportunityTriggerHandler.createFoloupTaskandField(trigger.new, Trigger.oldMap);
         }
    }  */

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            OpportunityTriggerHandler.populateDescriptionField(Trigger.new);
            OpportunityTriggerHandler.updateOpportunityDescription(Trigger.new, null);
            OpportunityTriggerHandler.preventOppCreation(Trigger.old);

        } else if(Trigger.isAfter){
            OpportunityTriggerHandler.createFoloupTaskandField(trigger.new, null);
            OpportunityTriggerHandler.populateRecentOpportunityAmount(Trigger.new);
        }
    }

    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            OpportunityTriggerHandler.updateOpportunityDescription(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.validateClosedLostReason(Trigger.new, Trigger.oldMap);


        } else if(Trigger.isAfter){
            OpportunityTriggerHandler.createFoloupTaskandField(trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.createTaskOnOpportunityStageChange(Trigger.new, Trigger.oldMap);
    
        }

        if(Trigger.isDelete){
            if(Trigger.isBefore){
                OpportunityTriggerHandler.preventDeleteOpportunity(Trigger.old);
            } else if(Trigger.isAfter){

            }
        }
    }
}