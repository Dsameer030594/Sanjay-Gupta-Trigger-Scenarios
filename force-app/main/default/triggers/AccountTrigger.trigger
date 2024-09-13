trigger AccountTrigger on Account (before insert, after insert, before update, after update) {


    if(Trigger.isInsert){
        if(Trigger.isBefore){
            AccountTriggerHandler.populateRating(Trigger.new, null);
            AccountTriggerHandler.copyBillingToShippingAdd(Trigger.new, null);

        } else if(Trigger.isAfter){
            AccountTriggerHandler.createContact(Trigger.new);
            AccountTriggerHandler.createOpportunity(Trigger.new);
            AccountTriggerHandler.createRelatedRecords(Trigger.new);
            
        }
    }

    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            AccountTriggerHandler.populateRating(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateDescription(Trigger.new, Trigger.oldMap);
             AccountTriggerHandler.copyBillingToShippingAdd(Trigger.new, Trigger.oldMap);
             AccountTriggerHandler.preventAccountEdit(Trigger.new);

        } else if(Trigger.isAfter){
            AccountTriggerHandler.updateaccField(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateContactPhoneusingMap(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateContactPhoneUsingSOQL(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateContactMailingAddressUsingMap(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateContactMailingAddressUsingSOQL(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateOpportunityStage(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventdeleteAccount(Trigger.old);
            AccountTriggerHandler.preventDeleteAccountforSysAdmin(Trigger.old);
            AccountTriggerHandler.preventDeleteAccountWithOpportunity(Trigger.old);
            AccountTriggerHandler.preventDeleteAccountWithCase(Trigger.old);

        } else if(Trigger.isAfter){

        }
    }
}