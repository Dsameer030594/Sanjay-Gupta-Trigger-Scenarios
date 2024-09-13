trigger ContactTrigger on Contact (after insert) {

if(Trigger.isInsert){
    if(Trigger.isBefore){

    } else if(Trigger.isAfter){
        
    }
}
}