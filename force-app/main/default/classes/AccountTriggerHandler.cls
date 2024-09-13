
public with sharing class AccountTriggerHandler {
    
    //Whenever an After update Triger is Executed on Account Record, Update a field named 'Last_After_Update_Execution_Time__c' 
//on the Account with the value of current Time.

    public static void updateaccField(List<Account> accList, Map<Id, Account> accOldMap){

        List<Account> newaccList = new List<Account>();

        for(Account acc : accList){
            Account accnew = new Account();
            accnew.Id = acc.Id;
                accnew.Last_After_Update_Execution_Time__c = Datetime.now();
                newaccList.add(accnew);
        }

        if(!newaccList.isEmpty()){
            update newaccList;  // Update the new Account records with the Last_After_Update_Execution_Time__c field
        }
    }

    // 12. Upon Account Creation if Industry is not null and having value as ‘Media’ then
    // populate Rating as Hot.

    public static void populateRating(List<Account> accList, Map<Id, Account> accOldMap){

        for(Account acc : accList){
            if((accOldMap == null && acc.Industry == 'Media') 
            || (acc.Industry == 'Media' && acc.Industry != accOldMap.get(acc.Id).Industry)){
                acc.Rating = 'Hot';
            }
        }
    }

    // 3 When an account inserts and CopyBillingToShipping (Custom Field) checkbox is
    //checked then automatically copy account billing address into account shipping
    // address.

    public static void copyBillingToShippingAdd(List<Account> accList, Map<Id, Account> accOldMap){

        for(Account acc : accList){
            if(acc.CopyBillingToShipping__c == True && acc.BillingCity != Null && acc.BillingCountry != Null 
            && acc.BillingPostalCode != null && acc.BillingState != null && acc.BillingStreet != null ){
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingState = acc.BillingState;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingStreet = acc.BillingStreet;
            }
        }
    }

    // 5. Create a related Contact when an Account is created.
    public static void createContact(List<Account> accList){

        List<Contact> contactList = new List<Contact>();

        for(Account acc : accList){
            Contact con= new Contact();
                con.FirstName = acc.Name + 'FN';
                con.LastName = acc.Name + 'LN';
                con.AccountId = acc.Id;
                contactList.add(con);
        }
         if(!contactList.isEmpty()){
        insert contactList;
        }
    }
    
   //6.  Create a related Opportunity when an Account is created
    public static void createOpportunity(List<Account> accList){

        List<Opportunity> oppList = new List<Opportunity>();

        for(Account acc : accList){
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = acc.Name + 'opp';
            opp.closeDate = System.Today();
            opp.StageName = 'Prospecting';
            oppList.add(opp);
        }
        if(!oppList.isEmpty()){
        insert oppList;
        }
    }

	// On Account create two checkbox fields labeled as Contact and Opportunity.
    //Now when a new Account record is created and if a particular Contact or
     //Opportunity checkbox is checked then create that related record. Also
    //Opportunity record should be created only if the Account record Active picklist is
    //populated with a Yes.

    public static void createRelatedRecords(List<Account> accList){

        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();

        for(Account acc : accList){
            if(acc.Create_Contact__c){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.LastName = acc.Name;
                conList.add(con);
            } else if(acc.Create_Opportunity__c && acc.Active__c == 'Yes'){
                Opportunity opp = new Opportunity();
                opp.Name = acc.Name;
                opp.AccountId = acc.Id;
                oppList.add(opp);
            }
        }

        if(conList.size() > 0){
            insert conList;
        }
        if(oppList.size() > 0){
            insert oppList;
        }
    }

    // 10. If the Account phone is updated then populate below message in description.
    // Description = Phone is Updated! Old Value : XXX & New Value

    public static void updateDescription(List<Account> accList, Map<Id, Account> accOldMap){

        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                acc.Description += 'Phone is Updated! Old Value :'+ accOldMap.get(acc.Id).Phone 
                +' & New Value :'+ acc.Phone;
            }
        }
    }

    // 14. If the Account phone is updated then populate the phone number on all
    // related Contacts (Home Phone field). [Using Map]

    public static void updateContactPhoneusingMap(List<Account> accList, Map<Id, Account> accOldMap){

        Map<Id, Account> accNewMap = new Map<Id, Account>();
        List<Contact> conList = new List<Contact>();

        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone && acc.Phone != null){
                accNewMap.put(acc.Id, acc);
            }
        }

        for(Contact con : [Select Id, AccountId, LastName, HomePhone from Contact WHERE AccountId IN: accNewMap.keySet()]){
            if(accNewMap.containsKey(con.AccountId)){
                con.HomePhone = accNewMap.get(con.AccountId).Phone;
                conList.add(con);
            }
            if(!conList.isEmpty()){
                update conList;
            }
        }
    }

    // 15. If the Account phone is updated then populate the phone number on all
    // related Contacts (Home Phone field). [Using Parent - child SOQL Query]

    public static void updateContactPhoneUsingSOQL(List<Account> accList, Map<Id, Account> accOldMap){

        Set<Id> accIds = new Set<Id>();
         List<Contact> conList = new List<Contact>();

        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone && acc.Phone != null){
                accIds.add(acc.Id);
            }   
        }

        for(Account acc: [Select Id, Name,
        (Select Id, AccountId, LastName, HomePhone from Contacts) 
        FROM Account WHERE Id IN: accIds]){

            if(accIds.contains(acc.Id) && acc.Contacts != null){
                for(Contact con : acc.Contacts){
                    con.HomePhone = acc.Phone;
                     conList.add(con);
                }
            }
        }
         if(!conList.isEmpty()){
                update conList;
            }
    }

    // 16. If the Account billing address is updated then update related contacts
    // mailing address. [Using Map]
    
    public static void updateContactMailingAddressUsingMap(List<Account> accList, Map<Id, Account> accOldMap){

        Map<Id, Account> accNewMap = new Map<Id, Account>();
        List<Contact> conList = new List<Contact>();

        for(Account acc : accList){
            if((acc.BillingCountry != accOldMap.get(acc.Id).BillingCountry) 
            ||(acc.BillingCity != accOldMap.get(acc.Id).BillingCity)
            ||(acc.BillingState != accOldMap.get(acc.Id).BillingState)
            ||(acc.BillingStreet != accOldMap.get(acc.Id).BillingStreet)
            ||(acc.BillingPostalCode != accOldMap.get(acc.Id).BillingPostalCode)
            && accOldMap != null){

                accNewMap.put(acc.Id, acc);
            }
        }

        for(Contact con : [Select Id, AccountId, MailingCountry, MailingCity, MailingState, 
        MailingStreet, MailingPostalCode FROM Contact Where AccountId IN: accNewMap.keySet()]){
            if(accNewMap.containsKey(con.AccountId)){
                con.MailingCountry = accNewMap.get(con.AccountId).BillingCountry;
                con.MailingCity = accNewMap.get(con.AccountId).BillingCity;
                con.MailingState = accNewMap.get(con.AccountId).BillingState;
                con.MailingStreet = accNewMap.get(con.AccountId).BillingStreet;
                con.MailingPostalCode = accNewMap.get(con.AccountId).BillingPostalCode;

                conList.add(con);
            }
        }
        if(!conList.isEmpty()){
        update conList;
        }
    }  

    // 17. If the Account billing address is updated then update related contacts
    // mailing address. [Using Parent-Child SOQL Query]

    public static void updateContactMailingAddressUsingSOQL(List<Account> accList, Map<Id, Account> accOldMap){

        Set<Id> accIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();

        for(Account acc : accList){
             if((acc.BillingCountry != accOldMap.get(acc.Id).BillingCountry) 
            ||(acc.BillingCity != accOldMap.get(acc.Id).BillingCity)
            ||(acc.BillingState != accOldMap.get(acc.Id).BillingState)
            ||(acc.BillingStreet != accOldMap.get(acc.Id).BillingStreet)
            ||(acc.BillingPostalCode != accOldMap.get(acc.Id).BillingPostalCode)
            && accOldMap != null){

               accIds.add(acc.Id);
            }
        }

        for(Account acc : [Select Id, BillingCountry, BillingCity, BillingState, 
        BillingStreet, BillingPostalCode, 
        (Select Id, AccountId, MailingCountry, MailingCity, MailingState, 
        MailingStreet, MailingPostalCode FROM Contacts) FROM Account WHERE Id IN: accIds]){
            
           if(accIds.contains(acc.Id) && acc.Contacts != null){
            for(Contact con : acc.Contacts){
                con.MailingCountry = acc.BillingCountry;
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.MailingStreet = acc.BillingStreet;
                con.MailingPostalCode = acc.BillingPostalCode;

                conList.add(con);
            }
           }
    }
    if(!conList.isEmpty()){
        update conList;
    }
} 

// 19. Write a trigger on Account when Account Active field is updated from ‘Yes’ 
// to ‘No’ then check all opportunities associated with the account. Update all
// Opportunities Stage to close lost if stage not equal to close won.

public static void updateOpportunityStage(List<Account> accList, Map<Id, Account> accOldMap){

    Set<Id> accIds = new Set<iD>();
    List<Opportunity> oppList = new List<Opportunity>();

    for(Account acc : accList){
        if(acc.Active__c == 'No' && accOldMap.get(acc.Id).Active__c == 'Yes' && acc.Active__c != accOldMap.get(acc.Id).Active__c){
          accIds.add(acc.Id);         
    }
}

for(Account acc : [Select Id, Name, Active__c,
(Select Id, AccountId, StageName from Opportunities) from Account Where Id IN: accIds]){

    if(accIds.contains(acc.Id) && acc.Opportunities != null){

        for(Opportunity opp : acc.Opportunities){
            if(opp.StageName != 'Closed Won' && opp.StageName  != 'Closed Lost'){
                opp.StageName = 'Closed Lost';
                oppList.add(opp);
            }
        }
        }
    }
    if(!oppList.isEmpty()){
        update oppList;
}
}

// 20. Account records cannot be deleted if active is Yes.

public static void preventdeleteAccount(List<Account> accList){

    for(Account acc : accList){
        if(acc.Active__c == 'Yes'){
            acc.addError('Active Account cannot be deleted');
        }
    }
}

// 21. Prevent account record from being edited if the record is created 7 days back.

public static void preventAccountEdit(List<Account> accList){

    for(Account acc: accList){
        if(acc.CreatedDate < (System.Today() - 6)){
            acc.addError('You cannot update account created 7 days back');
        }
    }
}

// 24. Write a trigger on Account and check only System Administrator profile 
// users should be able to delete an account.

public static void preventDeleteAccountforSysAdmin(List<Account> accList){

    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    for(Account acc : accList){
        if( UserInfo.getUserId() != p.Id){  // !System.isUserInRole('System Administrator') && acc.IsDeleted == true
            acc.addError('Only System Administrator users can delete accounts');
    }
}
}

// 26. Prevent deletion of an account if there is any opportunity related to that account.

public static void preventDeleteAccountWithOpportunity(List<Account> accList){

    Set<Id> accIds = new Set<Id>();

    for(Account acc : accList){
        accIds.add(acc.Id);
    }

    for(Account acc : [Select Id, Name,
    (Select Id, AccountId, Name from Opportunities) 
    from Account WHERE Id IN: accIds]){

        if(accIds.contains(acc.Id) && acc.Opportunities != null){
            acc.addError('You can not delete account where opportunities are available');
        }
    }
}

  // 27. Prevent deletion of an account if there is any case related to that account.
  
  public static void preventDeleteAccountWithCase(List<Account> accList){

    Set<Id> accIds = new Set<Id>();

    for(Account acc : accList){
        accIds.add(acc.Id);
    } 
    
    for(Account acc : [Select Id, Name,
    (Select Id, AccountId from Cases) 
    from Account WHERE Id IN: accIds]){

        if(accIds.contains(acc.Id) && acc.Cases != null){
            acc.addError('You can not delete account where Cases are available');
        }
    }
}
}