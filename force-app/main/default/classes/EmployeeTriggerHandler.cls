public with sharing class EmployeeTriggerHandler {
    
    // 28. When the Employee record is deleted then update ‘Left Employee Count’ on Account.

    public static void updateLeftEmployeeCount(List<Employee__c> deletedEmployees){

         // Get the related account IDs from the deleted Employee records
        Set<Id> accIds = new Set<Id>();

        for(Employee__c emp : deletedEmployees){
            if (emp.Account__c != null) {
                accIds.add(emp.Account__c);
            }
        }

         // Query the related accounts and their employees (using parent-to-child query)
        List<Account> accountsToUpdate = [SELECT Id, Left_Employee_Count__c,
        (SELECT Id FROM Employees__r) 
        FROM Account WHERE Id IN :accIds];

         // Update the Left_Employee_Count__c field based on the count of remaining employees
        for (Account acc : accountsToUpdate) {
         // Parent-to-child query gives the employee records
            acc.Left_Employee_Count__c = acc.Employees__r.size();
        }

        // Perform DML update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    // 29. Undelete Employee record and set Active as true.

    public static void undeleteEmployeeRecords(List<Employee__c> undeletedEmployees){

        // Iterate through the undeleted Employee records and set Active__c to true
        for (Employee__c emp : undeletedEmployees) {
            emp.Active__c = 'Yes';  // Assuming Active__c is the checkbox to mark an employee as active
        }
        // Update the Employee records
        update undeletedEmployees;
    }

    // 30. When the Employee record is undeleted then update ‘Left Employee Count’ on Account.

    public static void updateLeftEmployeeCountUndelete(List<Employee__c> undeletedEmployees){

         // Get the related account IDs from the undeleted Employee records
        Set<Id> accIds = new Set<Id>();

        for(Employee__c emp : undeletedEmployees){
            if (emp.Account__c != null) {
                accIds.add(emp.Account__c);
            }
        }

         // Query the related accounts and their employees (using parent-to-child query)
        List<Account> accountsToUpdate = [SELECT Id, Left_Employee_Count__c,
        (SELECT Id FROM Employees__r) 
        FROM Account WHERE Id IN :accIds];

         // Update the Left_Employee_Count__c field based on the count of remaining employees
        for (Account acc : accountsToUpdate) {
         // Parent-to-child query gives the employee records
            acc.Left_Employee_Count__c = acc.Employees__r.size();

        }

        // Perform DML update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
    }
    }

    // 31. When the Employee record is inserted, deleted and undeleted then update
   // ‘Present Employee Count’ on related Account. [Parent-Child SOQL]

    public static void updatePresentEmployeeCount(List<Employee__c> newEmployees){

        // Get the related account IDs from the Employee records
        Set<Id> accIds = new Set<Id>();

        for(Employee__c emp : newEmployees){
            if (emp.Account__c != null) {
                accIds.add(emp.Account__c);
            }
        }

        // Query the related accounts and their employees (using parent-to-child query)
        List<Account> accountsToUpdate = [SELECT Id, Present_Employee_Count__c,
        (SELECT Id, Active__c FROM Employees__r WHERE Active__c = 'Yes') from Account Where Id IN: accIds];

         // Update the Present Employee Count field based on the count of active employees
        for (Account acc : accountsToUpdate) {
            acc.Present_Employee_Count__c = acc.Employees__r.size();
        }

        // Perform DML update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
    }
    }
}
