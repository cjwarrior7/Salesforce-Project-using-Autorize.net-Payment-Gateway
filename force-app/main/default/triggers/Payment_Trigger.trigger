trigger Payment_Trigger on Payment__c (after insert ,after update) {
    if(trigger.isAfter &&(trigger.isInsert ||trigger.isUpdate)){
        RollupMethods.rollupPaymentsToRentalAgreement(trigger.newMap);   
        
    }
}