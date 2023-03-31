public with sharing class VerifyAddressController{
    
    public class recordInput
    {       
         @InvocableVariable
        public String objectName;
        
        @InvocableVariable
        public String fieldName;
        
        @InvocableVariable
        public String recordId;
        
        @InvocableVariable
        public String Street;
        
        @InvocableVariable
        public String City;
        
        @InvocableVariable
        public String State;
        
        @InvocableVariable
        public String Postalcode;
        
        @InvocableVariable
        public String Country;
    }
    
    // This is the method which we are calling from flow
    @InvocableMethod(label = 'Verify Address' description = 'To Verify the address')
    public static void verifyAddress(List <recordInput> Inputs)
    {
        String objectName = Inputs.get(0).objectName;
        String fieldname = Inputs.get(0).fieldName;
        String recordId = Inputs.get(0).recordId;
        String Street = Inputs.get(0).Street;
        String City = Inputs.get(0).City;
        String State = Inputs.get(0).State;
        String Postalcode = Inputs.get(0).Postalcode;
        String Country = Inputs.get(0).Country;        
        String address=Street+','+City+','+State+','+Postalcode+','+Country;   
		process(address,objectName,fieldname,recordId);
    }
    @future(callout=true)
    public static void process(String address,String objectName,String fieldname,String recordId)
    {
        Map<String,String> mapString = fetchapi(address);
        system.debug('mapString---'+mapString);
        UpdateValue(objectName,fieldname,recordId, mapString.get('line1'),  mapString.get('city'),  mapString.get('provinceOrState'),  mapString.get('postalOrZip'),  mapString.get('country'));
        return;
    }
    
    
    // This method is used to get all the Address fileds related to a particular Object
    @AuraEnabled(cacheable = true)
    public static Map<String,String> getAddressTypeFields(String strObjectName){
        Map<String, Schema.SObjectType> sObjectname = Schema.getGlobalDescribe(); //Returns a map of all sObject names
        Map<String,String> mapOfAddressTypeFields = new  Map<String,String>(); // It will contain the map of all the address type fields
        for(Schema.SObjectField fields :sObjectname.get(strObjectName).getDescribe().fields.getMap().Values()) {
            If(fields.getDescribe().getType() == Schema.DisplayType.ADDRESS) { 
                mapOfAddressTypeFields.put(fields.getDescribe().getName(),fields.getDescribe().getName());
                system.debug(mapOfAddressTypeFields);
            }
        }
        return mapOfAddressTypeFields;
    }
     
    
    //This method is used to get the record when a user click on particular Address field
    @AuraEnabled
    public static string  getFieldValue(String objectName,String fieldname,String recordId) {
        String q='select ' +fieldname+' from '+objectName+ ' where Id=\''+recordId +'\'	 WITH SECURITY_ENFORCED';  //Soql dynamic query for geeting records
        system.debug(q);
        
        SObject sobj=Database.query(q); 
        System.debug(sobj);
        System.Address addrType = (System.Address)sobj.get(fieldname); // It is used to get the address type fields
        //system.debug(addrType.getStreet());
        String res=addrType.getStreet()+','+addrType.getCity()+','+addrType.getState()+','+addrType.getPostalCode()+','+addrType.getCountry();
        return res;
    }
    
    
    // This method is used to Update the existing address record to the new one that is retrived by the PostGrid Api
    @AuraEnabled
    public static SObject UpdateValue(String objectName,String fieldname,String recordId,String Street,String City,String State, String Postalcode,String Country){
        recordId='\''+recordId+'\'';
        system.debug(recordId);
        String q='select ' +fieldname+' from '+objectName+ ' where Id='+recordId +' WITH SECURITY_ENFORCED';  //Soql dynamic query for geeting records
        system.debug(q);
        
        sobject sobj=Database.query(q); 
        System.debug(sobj);
        
        string sObjToString=String.valueOf(sobj); // It is used to convert the sobject to string
        List<String> strList = sObjToString.split(':');
        system.debug(strList[0]);
        
          // if the object is Account
        if(strList[0]=='Account') {
            Account accountRecord =(Account)sobj; //Converting sobject to Account       
            System.Address addrType = (System.Address)sobj.get(fieldname); // It is used to get the address type fields
            if(fieldname=='BillingAddress')
            {
                accountRecord.put('BillingStreet',Street);
                accountRecord.put('BillingCity',City);
                accountRecord.put('BillingState',State);
                accountRecord.put('BillingPostalCode',Postalcode);
                accountRecord.put('BillingCountry',Country);
            }
            else if(fieldname=='ShippingAddress'){
                accountRecord.put('ShippingStreet',Street);
                accountRecord.put('ShippingCity',City);
                accountRecord.put('ShippingState',State);
                accountRecord.put('ShippingPostalCode',Postalcode);
                accountRecord.put('ShippingCountry',Country);
            }
            
            if (Schema.sObjectType.Account.fields.BillingStreet.isUpdateable() && Schema.sObjectType.Account.fields.BillingCity.isUpdateable() && Schema.sObjectType.Account.fields.BillingState.isUpdateable() && Schema.sObjectType.Account.fields.BillingPostalCode.isUpdateable() && Schema.sObjectType.Account.fields.BillingCountry.isUpdateable() && Schema.sObjectType.Account.fields.ShippingStreet.isUpdateable() && Schema.sObjectType.Account.fields.ShippingCity.isUpdateable() && Schema.sObjectType.Account.fields.ShippingState.isUpdateable() && Schema.sObjectType.Account.fields.ShippingPostalCode.isUpdateable() && Schema.sObjectType.Account.fields.ShippingCountry.isUpdateable()) {
                update accountRecord;
            }
            
            system.debug(accountRecord);
            
        }
        
        // if the object is contact
        else if(strList[0]=='Contact')  {
            Contact contactRecord = (Contact)sobj; //Converting sobject to Contact      
            System.Address addrType = (System.Address)sobj.get(fieldname); // It is used to get the address type fields
            if(fieldname=='MailingAddress'){
                contactRecord.put('MailingStreet',Street);
                contactRecord.put('MailingCity',City);
                contactRecord.put('MailingState',State);
                contactRecord.put('MailingPostalCode',Postalcode);
                contactRecord.put('MailingCountry',Country);
            }
            else if(fieldname=='OtherAddress'){
                contactRecord.put('OtherStreet',Street);
                contactRecord.put('OtherCity',City);
                contactRecord.put('OtherState',State);
                contactRecord.put('OtherPostalCode',Postalcode);
                contactRecord.put('OtherCountry',Country);
            }

            if(Schema.sObjectType.Contact.fields.MailingStreet.isUpdateable() && Schema.sObjectType.Contact.fields.MailingCity.isUpdateable() && Schema.sObjectType.Contact.fields.MailingState.isUpdateable() && Schema.sObjectType.Contact.fields.MailingPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.MailingCountry.isUpdateable() && Schema.sObjectType.Contact.fields.OtherStreet.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCity.isUpdateable() && Schema.sObjectType.Contact.fields.OtherState.isUpdateable() && Schema.sObjectType.Contact.fields.OtherPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCountry.isUpdateable()){
                update contactRecord;
            }            
          
            system.debug(contactRecord);
        }
        
        // if the object is Lead
        else if(strList[0]=='Lead') {
            Lead leadRecord = (Lead)sobj; // Converting sobject to Lead
            System.Address addrType = (System.Address)sobj.get(fieldname); // It is used to get the address type fields
            if(fieldname=='Address'){
                leadRecord.put('Street',Street);
                leadRecord.put('City',City);
                leadRecord.put('State',State);
                leadRecord.put('PostalCode',Postalcode);
                leadRecord.put('Country',Country);
            }
            
            if(Schema.sObjectType.Lead.fields.Street.isUpdateable() && Schema.sObjectType.Lead.fields.City.isUpdateable() && Schema.sObjectType.Lead.fields.State.isUpdateable() && Schema.sObjectType.Lead.fields.PostalCode.isUpdateable() && Schema.sObjectType.Lead.fields.Country.isUpdateable()) {
                update leadRecord;   
            }
           
            system.debug(leadRecord);
        }
        
        return sobj;
    }
    
    //This method is used to Fetch the api of Postgrid
    @AuraEnabled
    public static Map<String,String> fetchapi(String address){
        Postgrid__c customSetting = SetupPackage.fetchCredentials()[0]; // Geeting data from custom Setting
        String apiKey = customSettingGenerateController.decryptMethod(customSetting.ApiKey__c);  // Geeting api key from custom Setting
        String baseURL = customSetting.Base_URL__c;  // Geeting Base Url from custom Setting
        String endPointURL = baseURL + 'intl_addver/verifications?includeDetails=true';  // Geeting endPointUrl from custom Setting
        
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(endPointURL);
        request.setHeader('x-api-key', apiKey);
        request.setMethod('POST');
        String body ='address='+address;
        request.setBody(body);   
        
        HttpResponse response = http.send(request);  
        
        //HttpResponse response = CalloutController.calloutMethod(endPointURL,'POST',new Map<String,String> {'x-api-key'=>apiKey,'Content-Type' =>'application/x-www-form-urlencoded'},body, true, true);
        
        Map<String,String> forResult=new Map<String,String>(); //   It will store response which we will send to component
        
        if(response.getStatusCode()!= 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
        else {  
            Map<string,Object> result=(Map<string,object>)JSON.deserializeUntyped(response.getBody());  // Storing body in Map
            system.debug(result);
            
            Map<string,Object> dataResponse=(Map<string,object>)result.get('data');
            system.debug(dataResponse);
            
            if(dataResponse.keyset().contains('error')) {
                String Error=(string)dataResponse.get('error'); // It will store error
                forResult.put('error',Error);
                system.debug(forResult);
            }
            else {
                
                String street=(string)dataResponse.get('line1');  //It will store street
                system.debug(street);
                
                String city=(string)dataResponse.get('city');  //It will store city
                system.debug(city);
                
                String state=(string)dataResponse.get('provinceOrState');  //It will store state
                system.debug(state);
                
                String postalcode=(string)dataResponse.get('postalOrZip');  //It will store zipCode
                system.debug(postalcode);
                
                String country=(string)dataResponse.get('country');  //It will store country
                system.debug(country);
                 
                
                forResult.put('city',city);
                forResult.put('country',country);
                forResult.put('line1',street);
                forResult.put('postalOrZip',postalcode);
                forResult.put('provinceOrState',state); 
            }           
            
        }  
        return forResult;
        
    }
      

    // This method is used for user configuration page
    @AuraEnabled
    public static Map<String,String> testApiKey(string apiKey, string baseURL){
        Map<String,String> forResult=new Map<String,String>(); // It is used for sending the Map to lwc component
        
         try
        {
            String address = '22-20 bay st, floor 11, toronto, on';
            String endPointURL = baseURL + 'intl_addver/verifications?includeDetails=true';
            String body ='address='+address;

            HttpResponse response = CalloutController.calloutMethod(endPointURL,'POST',new Map<String,String> {'x-api-key'=>apiKey},body, true, true);
            System.debug(response.getStatusCode());
            Map<string,Object> result=(Map<string,object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() != 200)
            {
                ErrorResponseWrapper errorResponse = (ErrorResponseWrapper) JSON.deserialize(response.getBody(), ErrorResponseWrapper.class);
         
                forResult.put('status','error'); 
                forResult.put('message',errorResponse.message);
            }
            else{
                 forResult.put('status','success');
                 forResult.put('message','Successfully Verified');        
            }
                      
        }
        catch(Exception e)
        {
            forResult.put('status','error');
            forResult.put('message',e.getMessage());
        }
        return forResult;
    
        
        
    }    
}