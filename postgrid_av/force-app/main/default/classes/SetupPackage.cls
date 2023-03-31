public with sharing class SetupPackage{
    //This method is used to get the data from custom setting
    @AuraEnabled(cacheable=true)
    public static list<postgrid__c> fetchCredentials(){
        List<postgrid__c> customSetting = new List<postgrid__c>();
        try {
         customSetting = [SELECT Id, ApiKey__c, Base_URL__c FROM postgrid__c WITH SECURITY_ENFORCED LIMIT 1];     
        } 
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());        
        }   
        return customSetting;
    }
  
}