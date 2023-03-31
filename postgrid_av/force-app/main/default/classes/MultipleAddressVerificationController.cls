public with sharing class MultipleAddressVerificationController{
    // This method is used to get all the Address fileds related to a particular Object
    @AuraEnabled
    public static Map<String,String> getAddressTypeFields(String ObjectName){
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe(); //Returns a map of all sObject names
        Map<String,String> mapOfAddressTypeFields = new  Map<String,String>();// It will contain the map of all the address type fields
        for(Schema.SObjectField fields :detail.get(ObjectName).getDescribe().fields.getMap().Values())  {
            if(fields.getDescribe().getType() == Schema.DisplayType.ADDRESS) { 
                mapOfAddressTypeFields.put(fields.getDescribe().getName(),fields.getDescribe().getName());
                system.debug(mapOfAddressTypeFields);
            }
        }
        return mapOfAddressTypeFields;
    }
    
    // This method is used to get all the Records  related to a particular object
    @AuraEnabled
    public static List<Sobject>  getData(String objectName,String fieldname) {	
        String q='select id,name, ' +fieldname+' from '+objectName +' WITH SECURITY_ENFORCED';  //Soql dynamic query for geeting records
        system.debug(q);
        
        List <sobject> slist=Database.query(q); 
        System.debug(slist);
        
        return slist;
    }
    
    // This method is used to get api response
    @AuraEnabled
    public static Map<String,Object> getCorrectData(List<String> recordIds,List<String> addressbody) {
        system.debug(addressbody);
        system.debug(recordIds);
        Map<String,object> mapList=new Map<String,object>();  // it will store response which we will send to component
        Map<String,String> forError=new Map<String,String>(); // it will store Error which we will send to component
        List<String> forCorrectAddress=new List<String>();
        List<String> AddressforCsv=new List<String>();
        List<String> forWrongAddress=new List<String>();
        List<Integer> forSameAddress=new List<Integer>();
        List<String> RightAddressId= new List<String>();
        List<String> WrongAddressId= new List<String>();
        List<String> ErrorMessage= new List<String>();
        Integer sameAddCount=0;
        String correctAddress='CorrectAddress';
        String wrongAddress='WrongAddress';
            
        Postgrid__c customSetting = SetupPackage.fetchCredentials()[0]; // Geeting data from custom Setting
        //system.debug('customSetting'+customSetting);
        String apiKey = customSettingGenerateController.decryptMethod(customSetting.ApiKey__c); // Geeting api key from custom Setting
        String baseURL = customSetting.Base_URL__c; // Geeting Base Url from custom Setting
        String endPointURL = baseURL + 'intl_addver/verifications/batch?geoData=true&includeDetails=true';  // Geeting endPointUrl from custom Setting 
        
        //  Wrapper class of Body
        MultipleAddressBodyWrapper BodyWrap=new MultipleAddressBodyWrapper(); 
        BodyWrap.addresses=addressbody;
        String  body = JSON.serialize(BodyWrap);
        system.debug(body);
        
        HttpResponse response = CalloutController.calloutMethod(endPointURL,'POST',new Map<String,String> {'x-api-key'=>apiKey,'Content-Type' =>'application/json'},body, true, true);
        system.debug('response ----'+response);
        if(response.getStatusCode()== 200){
            try{
                //  Wrapper class of Response
                MulipleAddressWrapperClass wrap=(MulipleAddressWrapperClass)JSON.deserialize(response.getBody(), MulipleAddressWrapperClass.class);
                //system.debug(wrap);	
                Integer rightCount=0;
                Integer wrongCount=0;
                Integer totalCount=0;
                
                for(integer i=0 ;i<wrap.data.results.size(); i++){  
                    mapList.put('totalSize',String.valueOf(wrap.data.results.size()));
                    totalCount=Integer.valueOf(wrap.data.results.size());
                    
                    MulipleAddressWrapperClass.cls_results address = wrap.data.results[i];
                    
                    if(address.verifiedAddress.summary.verificationStatus==null) {
                        String Message='"' + address.verifiedAddress.summary.message + '"'; 
                        system.debug(addressbody[i]);
                        string finalString = '"' + addressbody[i] + '"';     
                        forWrongAddress.add(recordIds[i]);       
                        forWrongAddress.add(finalString);
                        forWrongAddress.add(Message);               
                        wrongCount+=1;
                        mapList.put('wrongCount',String.valueOf(wrongCount));
                        mapList.put('WrongAddress',forWrongAddress);
                    }
                    else if(address.verifiedAddress.summary.verificationStatus!=null) {
                        String street=(string)address.verifiedAddress.line1;  //It will store street
                        //system.debug(street);    
                        String city=(string)address.verifiedAddress.city;  //It will store city
                        //system.debug(city);                         
                        String state=(string)address.verifiedAddress.provinceOrState;  //It will store state
                        //system.debug(state);                
                        String postalcode=(string)address.verifiedAddress.postalOrZip;  //It will store zipCode
                        //system.debug(postalcode);  
                        String country=(string)address.verifiedAddress.country;  //It will store country
                        // system.debug(country);  
                        
                        
                        string finalAddressString = '"' + street+',' + city+',' +state+',' +postalcode+',' +country + '"';  
                        //system.debug('addressbody[i]==='+addressbody[i]);
                        string aa= '"'+ addressbody[i]+'"';
                        //system.debug('finalAddressString==='+finalAddressString);
                        
                        if(aa==finalAddressString)
                        {
                           sameAddCount=sameAddCount+1;                         
                        }
                        system.debug(sameAddCount);
                        
                        forCorrectAddress.add(recordIds[i]);
                        forCorrectAddress.add(finalAddressString); 
                        
                        AddressforCsv.add(recordIds[i]);
                        AddressforCsv.add('"' + addressbody[i]+'"');
                        AddressforCsv.add(finalAddressString);
                        
                        RightAddressId.add(recordIds[i]);
                        mapList.put('RightId',RightAddressId);
                        mapList.put('address',forCorrectAddress);
                        mapList.put('Rightaddress',AddressforCsv);
                        mapList.put('Sameaddress',forSameAddress);
                        
                        rightCount+=1;  
                        mapList.put('rightCount',rightCount);
                    }                
                } 
                 forSameAddress.add(sameAddCount);  
                system.debug(forCorrectAddress);             
                system.debug('wrongCount '+wrongCount);
                system.debug('rightCount '+rightCount);
                system.debug('mapList=='+mapList);
                
                PostGrid_AV__ForReport__c dataReport= new PostGrid_AV__ForReport__c();
                dataReport.PostGrid_AV__TotalRecords__c=totalCount;
                dataReport.PostGrid_AV__Success__c=rightCount;
                dataReport.PostGrid_AV__Error__c=wrongCount;
                
                if (Schema.sObjectType.PostGrid_AV__ForReport__c.fields.PostGrid_AV__TotalRecords__c.isCreateable() && Schema.sObjectType.PostGrid_AV__ForReport__c.fields.PostGrid_AV__Success__c.isCreateable() && Schema.sObjectType.PostGrid_AV__ForReport__c.fields.PostGrid_AV__Error__c.isCreateable()){
                    insert dataReport;
                }
            }
            catch(Exception e) {
                system.debug('Error'+e.getMessage());
                forError.put('error',e.getMessage());
                system.debug('LineNumber'+e.getLineNumber());
            }
            
        }
        else {
            
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('bodyyyy+ '+response.getBody() ); 
            
        }
        system.debug(mapList);
        return mapList;
    }
    
    // This method is used to update the correct address which is coming from Api response
    @AuraEnabled
    public static void UpdateValue(String objectName,String fieldname,List<String> recordIds,List<String> Address){
        system.debug(objectName);
        system.debug(fieldname);
        system.debug(Address);
        system.debug(recordIds);
        
        String q='select Id, ' +fieldname+' from '+objectName+ ' where Id in :recordIds WITH SECURITY_ENFORCED ';  //Soql dynamic query for geeting records
        system.debug(q);
        
        Map<Id,sobject> sobj= new Map<Id,sobject>(Database.query(q)); 
        System.debug(sobj); 
        
        // if the object is Account
        if(objectName=='Account'){
            List<Account> accountRecordUpdated = new List<Account>();       
            
            if(fieldname=='BillingAddress'){
                for(Integer i=0; i<Address.size();i+=2){
                    String accId=Address[i];
                    String addrs=Address[i+1];
                    //system.debug(acc);
                    if(Address.size()!=0){
                        List<String> tempAddress = addrs.split(',');
                        System.debug('tempAddress -->'+tempAddress);
                        System.debug('size -->'+tempAddress.size());
                        Account acc = new Account();
                        acc.id=accId;
                        
                        if(tempAddress[0]=='"null'){
                            acc.BillingStreet='';
                        }
                        else{
                            acc.BillingStreet = tempAddress[0].substring(1, tempAddress[0].length());
                        }
                          
                        if(tempAddress[1]=='null'){
                            acc.BillingCity='';
                        }
                        else{
                            acc.BillingCity = tempAddress[1];
                        }
                        
                        if(tempAddress[2]=='null'){
                            acc.BillingState='';
                        }
                        else{
                            acc.BillingState = tempAddress[2];  
                        } 
                        
                        if(tempAddress[3]=='null'){
                            acc.BillingPostalCode='';
                        }
                        else{
                            acc.BillingPostalCode = tempAddress[3]; 
                        }
                        
                        if(tempAddress[4]=='null'){
                            acc.BillingCountry='';
                        }
                        else{
                            acc.BillingCountry = tempAddress[4].substring(0, tempAddress[4].length()-1);  
                        }

                        system.debug(acc);
                        accountRecordUpdated.add(acc);              
                    }   
                }              
            }
            else if(fieldname=='ShippingAddress') {
                for(Integer i=0; i<Address.size();i+=2) {
                    String accId=Address[i];
                    String addrs=Address[i+1];
                    
                    if(Address.size()!=0){
                        List<String> tempAddress = addrs.split(',');
                        System.debug('tempAddress -->'+tempAddress);
                        System.debug('size -->'+tempAddress.size());
                        
                            Account acc = new Account();
                            acc.id=accId;
                            
                        if(tempAddress[0]=='"null'){
                            acc.ShippingStreet='';
                        }
                        else{
                            acc.ShippingStreet = tempAddress[0].substring(1, tempAddress[0].length());
                        }
                        
                        if(tempAddress[1]=='null'){
                            acc.ShippingCity='';
                        }
                        else{
                            acc.ShippingCity = tempAddress[1];                           
                        }
                        
                        if(tempAddress[2]=='null'){
                            acc.ShippingState='';
                        }
                        else{
                            acc.ShippingState = tempAddress[2];   
                        } 
                        
                        if(tempAddress[3]=='null'){
                            acc.ShippingPostalCode='';
                        }
                        else{
                            acc.ShippingPostalCode = tempAddress[3];
                        }
                        
                        if(tempAddress[4]=='null'){
                            acc.ShippingCountry='';
                        }
                        else{
                            acc.ShippingCountry = tempAddress[4].substring(0, tempAddress[4].length()-1); 
                        }
                                                
                         accountRecordUpdated.add(acc);
                                                
                    }
                    
                }
            }
            
            
            try {
                if(accountRecordUpdated.size()!=0) {
                    if (Schema.sObjectType.Account.fields.BillingStreet.isUpdateable() && Schema.sObjectType.Account.fields.BillingCity.isUpdateable() && Schema.sObjectType.Account.fields.BillingState.isUpdateable() && Schema.sObjectType.Account.fields.BillingPostalCode.isUpdateable() && Schema.sObjectType.Account.fields.BillingCountry.isUpdateable() && Schema.sObjectType.Account.fields.ShippingStreet.isUpdateable() && Schema.sObjectType.Account.fields.ShippingCity.isUpdateable() && Schema.sObjectType.Account.fields.ShippingState.isUpdateable() && Schema.sObjectType.Account.fields.ShippingPostalCode.isUpdateable() && Schema.sObjectType.Account.fields.ShippingCountry.isUpdateable()){
                        update accountRecordUpdated;
                    }         
                }
                
            }
            catch (Exception e){
                system.debug('Error'+e.getMessage());
            }
            system.debug('accountRecordUpdated=== '+accountRecordUpdated);
            
        }
        
        // if the object is contact
        else if(objectName=='Contact'){
            List<Contact> contactRecordUpdated = new List<Contact>();         
            if(fieldname=='MailingAddress'){
                
                for(Integer i=0; i<Address.size();i+=2){
                    String conId=Address[i];
                    String addrs=Address[i+1];
                    
                    if(Address.size()!=0){
                        List<String> tempAddress = addrs.split(',');
                        System.debug('tempAddress -->'+tempAddress);
                        System.debug('tempAddress -->'+tempAddress.size());
                        
                        Contact con = new Contact();
                        con.id=conId;
                        
                        if(tempAddress[0]=='"null'){
                             con.MailingStreet='';
                        }
                        else{
                            con.MailingStreet = tempAddress[0].substring(1, tempAddress[0].length());    
                        }
                        
                        if(tempAddress[1]=='null'){
                            con.MailingCity='';
                        }
                        else{
                             con.MailingCity = tempAddress[1];
                            
                        }
                        
                        if(tempAddress[2]=='null'){
                            con.MailingState='';
                        }
                        else{
                            con.MailingState = tempAddress[2];      
                        } 
                        
                        if(tempAddress[3]=='null'){
                            con.MailingPostalCode='';
                        }
                        else{
                            con.MailingPostalCode = tempAddress[3];
                        }
                        
                        if(tempAddress[4]=='null'){
                            con.MailingCountry ='';
                        }
                        else{
                            con.MailingCountry = tempAddress[4].substring(0, tempAddress[4].length()-1);
                        }
                           
                        contactRecordUpdated.add(con);                
                    }      
                }
            }
            
            else if(fieldname=='OtherAddress'){
                for(Integer i=0; i<Address.size();i+=2){
                    String conId=Address[i];
                    String addrs=Address[i+1];
                    if(Address.size()!=0){
                        
                        List<String> tempAddress = addrs.split(',');
                        System.debug('tempAddress -->'+tempAddress);
                        System.debug('tempAddress -->'+tempAddress.size());
                        
                        Contact con = new Contact();
                        con.id=conId;
                        
                        if(tempAddress[0]=='"null'){
                            con.OtherStreet='';
                        }
                        else{
                            con.OtherStreet = tempAddress[0].substring(1, tempAddress[0].length());  
                        }
                        
                        if(tempAddress[1]=='null'){
                            con.OtherCity='';
                        }
                        else{
                            con.OtherCity = tempAddress[1];     
                        }
                        
                        if(tempAddress[2]=='null'){
                            con.OtherState='';
                        }
                        else{
                            con.OtherState = tempAddress[2];                            
                        } 
                        
                        if(tempAddress[3]=='null'){
                            con.OtherPostalCode='';
                        }
                        else{
                            con.OtherPostalCode = tempAddress[3];
                        }
                        
                        if(tempAddress[4]=='null'){
                            con.OtherCountry ='';
                        }
                        else{
                            con.OtherCountry = tempAddress[4].substring(0, tempAddress[4].length()-1);
                        }
                        contactRecordUpdated.add(con);                           
                    }                  
                }
            }
            
            try{
                if(contactRecordUpdated.size()!=0){
                    if(Schema.sObjectType.Contact.fields.MailingStreet.isUpdateable() && Schema.sObjectType.Contact.fields.MailingCity.isUpdateable() && Schema.sObjectType.Contact.fields.MailingState.isUpdateable() && Schema.sObjectType.Contact.fields.MailingPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.MailingCountry.isUpdateable() && Schema.sObjectType.Contact.fields.OtherStreet.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCity.isUpdateable() && Schema.sObjectType.Contact.fields.OtherState.isUpdateable() && Schema.sObjectType.Contact.fields.OtherPostalCode.isUpdateable() && Schema.sObjectType.Contact.fields.OtherCountry.isUpdateable()){
                        update contactRecordUpdated;
                    }                     
                }
                
            }
            catch (Exception e) {
                system.debug('Error'+e.getMessage());
            }
            system.debug(contactRecordUpdated);
            
        }
        
        // if the object is contact 
        
        else if(objectName=='Lead') {
            
            List<Lead> leadRecordUpdated = new List<Lead>();        
            if(fieldname=='Address'){
                for(Integer i=0; i<Address.size();i+=2){
                    String lId=Address[i];
                    String addrs=Address[i+1];
                    if(Address.size()!=0){
                        List<String> tempAddress = addrs.split(',');
                        System.debug('tempAddress -->'+tempAddress);
                        System.debug('tempAddress -->'+tempAddress.size());
                        
                        Lead l = new Lead();
                        l.id=lId;
                        
                        if(tempAddress[0]=='"null'){
                            l.Street='';
                        }
                        else{
                            l.Street = tempAddress[0].substring(1, tempAddress[0].length());   
                        }
                        
                        if(tempAddress[1]=='null'){
                            l.City='';
                        }
                        else{
                            l.City = tempAddress[1];    
                        }
                        
                        if(tempAddress[2]=='null'){
                            l.State='';
                        }
                        else{
                            l.State = tempAddress[2];       
                        } 
                        
                        if(tempAddress[3]=='null'){
                            l.PostalCode='';
                        }
                        else{
                            l.PostalCode = tempAddress[3];
                        }
                        
                        if(tempAddress[4]=='null'){
                            l.Country ='';
                        }
                        else{
                            l.Country = tempAddress[4].substring(0, tempAddress[4].length()-1);
                        }                
                        leadRecordUpdated.add(l);   
                    }        
                } 
            }
            try{
                if(leadRecordUpdated.size()!=0) {
                    if(Schema.sObjectType.Lead.fields.Street.isUpdateable() && Schema.sObjectType.Lead.fields.City.isUpdateable() && Schema.sObjectType.Lead.fields.State.isUpdateable() && Schema.sObjectType.Lead.fields.PostalCode.isUpdateable() && Schema.sObjectType.Lead.fields.Country.isUpdateable()){
                        update leadRecordUpdated;    
                    }   
                }
                
            }
            catch (Exception e){	
                system.debug('Error'+e.getMessage());
            }
            system.debug(leadRecordUpdated);
        }
    }  
}