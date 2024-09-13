public with sharing class ContactTriggerHandler {
    
    // 32. Upon contact creation an email should be sent to email populated on 
    // Contact with specified template.

    public static void sendEmailOnContactCreation(List<Contact> conList){

        List<Messaging.SingleEmailMessage> emailList = new List<Messageing.SingleEmailMessage>();

        for(Contact con : conList){
            if(con.Email != null){

                Messaging.SingleEmailMessage email = new Messageing.SingleEmailMessage();

                email.setToAddresses(new List<String> {});
                email.setSubject();
                email.setPlainTextBody()

                emailList.add(email);

            }
        }
    }

}