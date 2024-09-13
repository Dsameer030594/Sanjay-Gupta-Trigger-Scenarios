trigger CaseTrigger on SOBJECT (after insert) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){

        }else if(Trigger.isAfter){
            CaseTriggerHandler.updateLateCaseNo(Trigger.new);
        }
    }
}