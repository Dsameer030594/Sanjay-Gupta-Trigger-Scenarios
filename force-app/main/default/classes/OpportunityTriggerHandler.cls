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
    insert taskList;
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

// 8th video and question
// Trigger to find sum of all related Opportunities Amount of an Account
// and update the Account record with the sum.

    public static void updateAccountSumOfOpportunitiesAmount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
// Set to store Account Ids that need to be updated
Set<Id> accIds = new Set<Id>();

// Identify accounts that need to be updated
for (Opportunity opp : oppList) {
    if (opp.AccountId != null) {
        // If it's an insert or amount has changed
        if ((opp.Amount != null && oppOldMap == null) || (oppOldMap != null && opp.Amount != oppOldMap.get(opp.Id).Amount)) {
            accIds.add(opp.AccountId);
        }
    }
}

// Proceed only if there are accounts to update
if (!accIds.isEmpty()) {
    // Map to store the total opportunity amounts per account
    Map<Id, Decimal> oppAmountMap = new Map<Id, Decimal>();

    // Query all opportunities related to the accounts and calculate the sum
    for (Opportunity opp : [SELECT AccountId, Amount 
                            FROM Opportunity 
                            WHERE AccountId IN :accIds]) {
        if (opp.Amount != null) {
            // Accumulate the opportunity amounts by account
            if (oppAmountMap.containsKey(opp.AccountId)) {
                oppAmountMap.put(opp.AccountId, oppAmountMap.get(opp.AccountId) + opp.Amount);
            } else {
                oppAmountMap.put(opp.AccountId, opp.Amount);
            }
        }
    }

    // List to hold updated accounts
    List<Account> accList = new List<Account>();

    // Iterate over the account IDs and prepare account updates
    for (Id accId : accIds) {
        Decimal totalAmount = oppAmountMap.containsKey(accId) ? oppAmountMap.get(accId) : 0;

        Account acc = new Account();
        acc.Id = accId;
        acc.Total_Opportunity_Amount__c = totalAmount;
        accList.add(acc);
    }

    // Update the accounts with the summed Opportunity Amounts
    if (!accList.isEmpty()) {
        update accList;
    }
}
}

// Trigger 16 (TCS Question): Update the Parent Account 
//Field with The Opportunity Name that has Highest Amount

public static void maximumAmountOppNameOnAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){

// Set to store Account Ids that need to be updated
Set<Id> accIds = new Set<Id>();

// Iterate over the opportunity list to identify accounts that need to be updated
for (Opportunity opp : oppList) {
    if (opp.AccountId != null) {
        // Check if opportunity amount has changed or it's a new opportunity
        if (oppOldMap == null || opp.Amount != oppOldMap.get(opp.Id).Amount) {
            accIds.add(opp.AccountId);
        }
    }
}

// Proceed only if there are accounts to update
if (!accIds.isEmpty()) {
    // Map to store the Opportunity with the highest Amount per Account
    Map<Id, Opportunity> highestOppMap = new Map<Id, Opportunity>();

    // Query Opportunities and get the related Account and Amount
    List<Opportunity> oppListWithAccounts = [SELECT Id, AccountId, Name, Amount
        FROM Opportunity
        WHERE AccountId IN :accIds
        ORDER BY Amount DESC];

    // Iterate over the Opportunity list and keep track of the highest Amount per Account
    for (Opportunity opp : oppListWithAccounts) {
        if (opp.Amount != null) {
            if (!highestOppMap.containsKey(opp.AccountId) 
            || opp.Amount > highestOppMap.get(opp.AccountId).Amount) {
                highestOppMap.put(opp.AccountId, opp);  // Store the Opportunity with the highest Amount
            }
        }
    }

    // List to hold updated accounts
    List<Account> accList = new List<Account>();

    // Iterate over the account IDs and prepare account updates
    for (Id accId : accIds) {
        if (highestOppMap.containsKey(accId)) {
            Opportunity highestOpp = highestOppMap.get(accId);

            Account acc = new Account();
            acc.Id = accId;
            acc.Maximum_Opp_Amount_Name__c = highestOpp.Name;  // Assuming this is the custom field for storing the Opportunity Name
            accList.add(acc);
        }
    }

    // Update the accounts with the highest Opportunity Name
    if (!accList.isEmpty()) {
        update accList;
    }
}
}

// 8.Whenever TestPhoneOpportunity__c field in opportunity is updated,
// its related field (TestPhoneAccount__c) in Account and 
// (TestPhoneContact__c ) in Contact should get updated with the updated value with 
//TestPhoneOpportunity__c

public static void updaterelatedAccNadConField(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
    
// Map to store opportunities by AccountId
Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
List<Account> accList = new List<Account>();
List<Contact> conList = new List<Contact>();
    
    // Collect only Opportunities where the TestPhoneOpportunity__c field has changed
    for(Opportunity opp : oppList){
        if(oppOldMap != null && opp.TestPhoneOpportunity__c != oppOldMap.get(opp.Id).TestPhoneOpportunity__c){
            if(opp.AccountId != null){
                oppMap.put(opp.AccountId, opp);
            }
        }
    }
    // Update related Account and Contact records
    if(!oppMap.isEmpty()){
            // Query related Accounts and their Contacts
    // Child-to-Parent query for Account, and Parent-to-Child subquery for Contacts

    for(Account acc : [SELECT Id, Name, TestPhoneAccount__c,
    (SELECT Id, AccountId, TestPhoneContact__c FROM Contacts) FROM Account WHERE Id IN: oppMap.keySet()]){

        if(oppMap.containsKey(acc.Id)){
            acc.TestPhoneAccount__c = oppMap.get(acc.Id).TestPhoneOpportunity__c;
            accList.add(acc);
        }
        for(Contact con : acc.Contacts){
            con.TestPhoneContact__c = oppMap.get(con.AccountId).TestPhoneOpportunity__c;
            conList.add(con);
        }
        }
        // Performing updates
        if (!accList.isEmpty()) {
            update accList;
        }
        if (!conList.isEmpty()) {
            update conList;
        }
    }
    }                

// Trigger 41 : Write An Apex Trigger to show Max closed Opportunity Amount
// on Account without using Aggregate Function

    public static void updateMaxClosedOpportunityAmount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap) {
    // Set to store the Account IDs for which we need to find the max Opportunity Amount
    Set<Id> accIds = new Set<Id>();

        // Add AccountId from all Opportunity records in the trigger (new opportunities or changes in Amount)
    for (Opportunity opp : oppList) {
        if (opp.AccountId != null && opp.IsClosed == TRUE) {
            accIds.add(opp.AccountId);
        }
    }
    // Proceed only if there are accounts to update
    if (!accIds.isEmpty()) {
        // Map to hold the maximum Opportunity amount for each Account
        Map<Id, Decimal> maxAmountMap = new Map<Id, Decimal>();
        
        // Query all closed Opportunities for the given Account Ids
        List<Opportunity> opps = [ SELECT AccountId, Amount FROM Opportunity 
        WHERE AccountId IN :accIds AND IsClosed = TRUE];
        
        // Loop through Opportunities to find the maximum amount for each Account
        for(Opportunity opp : opps) {
            // Get the current max amount for the Account, or initialize it to null
            Decimal currentMaxAmount = maxAmountMap.get(opp.AccountId);
            
            // If no maxAmount found for the account, or if the current opportunity amount is greater, update the map
            if (currentMaxAmount == null || opp.Amount > currentMaxAmount) {
                maxAmountMap.put(opp.AccountId, opp.Amount);
            }
        }
        
        // List to hold updated Account records
        List<Account> accList = new List<Account>();
        
        // Update the Account records with the maximum closed Opportunity amount
        for (Id accId : accIds) {
            if (maxAmountMap.containsKey(accId)) {
                Account acc = new Account();
                acc.Id = accId;
                acc.Max_Closed_Opp_Amount__c = maxAmountMap.get(accId); // Assuming this is the custom field
                accList.add(acc);
            }
        }
        
        // Perform DML update on Accounts
        if (!accList.isEmpty()) {
            update accList;
        }
    }
}
// Trigger 52: IBM Interview Scenario : Whenever an Opportunity is created or updated
// with Amount Greater than 10000,
// then send an Email to the record Owner

public static void sendEmaiToOwner(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
    
    // List to hold Opportunities with Amount greater than 10000
    Set<Id> ownerIds = new Set<Id>();
    
    for(Opportunity opp : oppList){
        if((oppOldMap == null && opp.Amount != null && opp.Amount >10000) || (oppOldMap != null && opp.Amount != oppOldMap.get(opp.Id).Amount && opp.Amount >10000)){
            ownerIds.add(opp.OwnerId);
        }
    }
    
    if(!ownerIds.isEmpty()){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : [Select Id, OwnerId, Name, Amount from Opportunity where OwnerId IN: ownerIds]){
            
                // Create an email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // Set email parameters
            email.SetToAddresses(new List<String> {opp.OwnerId});
            email.setSubject('Opportunity Amount exceeding 10000');
            email.setPlainTextBody('Dear ' + opp.Owner.Name + ',\n\n' +
                                'An Opportunity with the name "' + opp.Name + '" has been ' +
                                'created or updated with an Amount exceeding $10,000.\n\n' +
                                'Thank you,\nYour Salesforce Administrator');
            
            emailsToSend.add(email);
            
        }
        // Send emails
    Messaging.sendEmail(emailsToSend);
    }
    
}

// b. : Roll up count of High Valued opportunities under parent account for 
// each opportunity with amount>5000 and Stage='Closed Won' when Opportunity is created, deleted or 
// undeleted and when the Opportunity is updated and amount changes and amount >5000 and 
//Stage changes to 'Closed Won'

public static void rollupHighValueOppONAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
    
    //Account Ids set to hold unique parent account for each opportunity
    Set<Id> accIds=new Set<Id>();
    List<Account> accList = new List<Account>();
    
    // Determine which Accounts need to be updated
    for(Opportunity opp : oppList){
        if(opp.AccountId != null && opp.Amount > 5000 && opp.StageName == 'Closed Won' && opp.Amount != oppOldMap.get(opp.Id).Amount ){
            accIds.add(opp.AccountId);
        }
    }
    // Query Accounts and their Opportunities meeting the criteria
    if(!accIds.isEmpty()){
    for(Account acc :[Select Id, Name, High_Value_Opportunities__c,
    (Select Id, AccountId, Amount, StageName from Opportunities WHERE Amount > 5000 AND StageName = 'Closed Won')
                        from Account where Id IN: accIds]){
                            // Update the High_Value_Opportunities__c field for each Account
                            if(accIds.contains(acc.Id)){
                                acc.High_Value_Opportunities__c = acc.Opportunities.size();
                                accList.add(acc);
                            }
                        }
            // Perform the update outside of the loop
    if (!accList.isEmpty()) {
        update accList;
    }
    }                
}
// Roll up sum of amount of each opportunity with StageName=='Negotiation/Review' under parent account after
//insert, delete or undelete and when the Opportunity is updated and amount is not empty and amount changes and Stage
//changes to 'Negotiation/Review' OR Stage is 'Negotiation/Review' and amount changes but is not 0 or null or negative

public static void rollupSumOfOppAmountBasedOnStage(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
    
    // Set to hold unique account IDs for opportunities to be processed
    Set<Id> accIds = new Set<Id>();
    List<Account> accList = new List<Account>();
    
    // Determine which Accounts need to be updated
    for(Opportunity opp : oppList){
        if((opp.AccountId != null && opp.Amount != null && opp.StageName == 'Negotiation/Review' && oppOldMap == null) || 
            (oppOldMap != null && opp.Amount != null && opp.Amount != oppOldMap.get(opp.Id).Amount && opp.Amount > 0 
            && opp.StageName == 'Negotiation/Review' && opp.StageName != oppOldMap.get(opp.Id).StageName)){
                
                accIds.add(opp.AccountId);   
            }
        // Query Accounts and their Opportunities meeting the criteria
        // Update the rollUpAmount_with_Stage_is_Negotation__c field for each Account
        for(Account acc : [Select Id, Name, rollUpAmount_with_Stage_is_Negotation__c, 
                            (Select Id, AccountId, Amount, StageName from Opportunities where Amount >0 AND StageName = 'Negotiation/Review')from Account where Id IN: accIds]){
                                Decimal totalAmount = 0;
                                for (Opportunity opps : acc.Opportunities) {
                                    totalAmount += opps.Amount;
                                }
                                acc.rollUpAmount_with_Stage_is_Negotation__c = totalAmount;    
                            }          
        // Update Accounts
        if (!accList.isEmpty()) {
            update accList;
        }         
    }   
}  
}