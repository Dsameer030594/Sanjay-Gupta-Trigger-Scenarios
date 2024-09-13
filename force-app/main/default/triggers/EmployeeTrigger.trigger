trigger EmployeeTrigger on Employee__c (after delete, after undelete) {

   if(Trigger.isInsert && Trigger.isAfter){
        EmployeeTriggerHandler.updatePresentEmployeeCount(Trigger.new);
    }
   
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            EmployeeTriggerHandler.updateLeftEmployeeCount(Trigger.old);
            EmployeeTriggerHandler.updatePresentEmployeeCount(Trigger.old);
        }
    }

    if(Trigger.isUnDelete && Trigger.isAfter){

        EmployeeTriggerHandler.undeleteEmployeeRecords(Trigger.new);
        EmployeeTriggerHandler.updateLeftEmployeeCountUndelete(Trigger.new);
        EmployeeTriggerHandler.updatePresentEmployeeCount(Trigger.new);

    }
}