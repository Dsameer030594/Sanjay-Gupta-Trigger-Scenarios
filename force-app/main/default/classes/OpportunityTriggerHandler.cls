public class OpportunityTriggerHandler {

    // When an Opportunity is Marked as "Closed Won",
    // Create follow-up tasks for the sales team to engage with the customer, schedule a call,
    // and send a thank you email
    // also update the next steps on Opportunity to "Onboard a Contract".
    
    public static void createFoloupTaskandField(List<Opportunity>  oppList, Map<Id, Opportunity> oppOldMap){
        
        List<Task> taskList = new List<Task>();

        for(Opportunity opp : oppList){
            if((opp.StageName != oppOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won')
            || (oppOldMap == null && opp.StageName == 'Closed Won')){

                opp.NextStep = 'Onboard a Contract';

                Task tk1 = new Task();
                tk1.Subject = 'Engage With Customer';
                tk1.WhatId = opp.Id;
                taskList.add(tk1);

                Task tk2 = new Task();
                tk1.Subject = 'schedule a call';
                tk1.WhatId = opp.Id;
                taskList.add(tk2);

                Task tk3 = new Task();
                tk1.Subject = 'send a thank you email';
                tk1.WhatId = opp.Id;
                taskList.add(tk3);
            }
        }
    }

    //2. Upon Opportunity Creation if Amount is not null and is greater than 100000 then
    //populate ‘Hot Opportunity’ in description field.

    public static void populateDescriptionField(List<Opportunity> oppList){

        for(Opportunity opp : oppList){
            if(opp.Amount != null && opp.Amount > 100000){
                opp.Description = 'Hot Opportunity';
            }
        }
    }

    // 8 Account records should have a field named ‘Recent Opportunity Amount’. 
    //It should contain the opportunity amount of the latest created opportunity on account.

    public static void populateRecentOpportunityAmount(List<Opportunity> oppList){

        List<Account> accList= new List<Account>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != null && opp.Amount != null){

                Account acc = new Account();
                acc.Id = opp.AccountId;
                acc.Recent_Opportunity_Amount__c = opp.Amount;
                accList.add(acc);
            }
        }

        if(accList.size() > 0){
            update accList;
        }

    }

    // 13. If opportunity Stage is updated upon its creation or update then update
    // description as either 'Opp is Closed Lost' or 'Opp is Closed Won' or 'Opp is Open'.

    public static void updateOpportunityDescription(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){

        for(Opportunity opp : oppList){
            if((opp.StageName != null && oppOldMap == null) || 
            (opp.StageName != oppOldMap.get(opp.Id).StageName)){

                if(opp.StageName == 'Closed Won'){
                    opp.Description = 'Opp is Closed Won';
                } else if(opp.StageName == 'Closed Won'){
                    opp.Description = 'Opp is Closed Lost';
                }else {
                    opp.Description = 'Opp is Open';
                }
            }
        }
    }

    // 18. When a Opportunity Stage (field) is changed, create a Task record on 
    // Opportunity and assign it to Logged In User/Opportunity Owner / Any User.

    public static void createTaskOnOpportunityStageChange(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){

        List<Task> taskList = new List<Task>();

        for(Opportunity opp : oppList){
            if(oppOldMap == null || opp.StageName != oppOldMap.get(opp.Id).StageName){
                Task tk = new Task();
                tk.WhatId = opp.Id;
                tk.Subject = 'Create a new Task';
                tk.Priority = 'Normal';
                tk.Status = 'Open';
                tk.OwnerId = opp.OwnerId;   // UserInfo.getUserId()
                taskList.add(tk);
        }
    }
      If(taskList.size( ) > 0){
        insert taskList;
        }
}

// Apply validation using addError( ) method in trigger. 
// While Creation of Opportunity is Amount is null then throw an error message.

public static void preventOppCreation(List<Opportunity> oppList){
    
    for(Opportunity opp : oppList){
        if(opp.Amount == null){
            opp.addError('Amount field can not be null');
        }
    }
}

// 23. When an opportunity is updated to Closed Lost and Closed Lost Reason 
//(field) is not populated then throw validation error that ‘Please populate
// Closed Lost Reason’ on opportunity. [before update]

public static void validateClosedLostReason(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){

    for(Opportunity opp : oppList){
        if(opp.StageName == 'Closed Lost' && opp.StageName != oppOldMap.get(opp.Id).StageName && opp.Closed_Lost_Reason__c == null){
            opp.addError('Please populate Closed Lost Reason on opportunity');
        }
    }
}

// 25. If an opportunity is closed then, no one should be able to delete it except
// the user having a System Administrator profile.

public static void preventDeleteOpportunity(List<Opportunity> oppList){

    Profile p = [Select Id, Name from Profile WHERE Name = 'System Administrator'];

    for(Opportunity opp : oppList){
        if(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won'){
            if(UserInfo.getUserId() != p.Id){
                opp.addError('You are not authorized to delete this opportunity. Only System administrator can delete opportunity');
            }
        }
    }
    }

}