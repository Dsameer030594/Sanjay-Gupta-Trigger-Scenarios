public with sharing class CaseTriggerHandler {
    
    // Our Company's salesforce System manages customer support cases. Each case can have multiple related child cases. 
    // The company wants to implements a feature that automatically calculates and
    //  updates the Total resolution days for parent cases based on the resolution days of their related child cases.
    //  Additionally, we want to ensure that any changes made to child cases are accurately reflected in the parent case's resulation time.
    //  
    //  example: 
    //  Parent case (P-001) has Three child cases:
    //  Child case 1 (C-001) with resolution_days__c = 5
    //  Child case 2 (C-002) with resolution_days__c = 3
    //  Child case 3 (C-003) with resolution_days__c = 2
    //  
    //  If a Forth child case (C-004) is added with a resolutin_Days__c = 4, The Parent case's Total_Resolution_Days__c should be updated to 14.
    
    
    
    
    //Questions to Ask:
    //How many level deep this hierarchy can go? -- 1 level deep
    //Can resolution days updated Manually ?? -- No, Read Only field
    //When does the Resolution days field Update - on case Status update to resolved
    //Can a case be created in resolved Staus directly? - Yes

   
    
}