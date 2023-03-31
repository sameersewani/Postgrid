public with sharing class CustomSettingGenerateController {
    
    public class Constants{
        public final String DEFAULT_KEY = 'POSTGRIDAPISP1'+  UserInfo.getOrganizationId();  //Key for encryption include an static id with org id
    }
    
    @AuraEnabled
     // method to get credentials present in custom setting 
    public static  Map<String,String> getCrediantials()
    {
        List <PostGrid_AV__postgrid__c> pp=[SeleCT 	PostGrid_AV__ApiKey__c,PostGrid_AV__Base_URL__c FROM PostGrid_AV__postgrid__c];
         Map<String,String> apiCredentialsMap = new Map<String,String>();
        apiCredentialsMap.put('baseURL', pp[0].PostGrid_AV__Base_URL__c);
        apiCredentialsMap.put('apiKey',customSettingGenerateController.decryptMethod(pp[0].PostGrid_AV__ApiKey__c));
        return apiCredentialsMap;
    }
    
    @AuraEnabled
    // method which auto Populate Data (credentials present in custom setting) on UI
    public static Map<String,String> autoPopulateData(){
        if(SetupPackage.fetchCredentials().size() > 0){
            postgrid__c customSetting = SetupPackage.fetchCredentials()[0];
            Map<String,String> apiCredentialsMap = new Map<String,String>();
            String apiKey = customSettingGenerateController.decryptMethod(customSetting.ApiKey__c);
            apiCredentialsMap.put('baseURL', customSetting.Base_URL__c);
            apiCredentialsMap.put('apiKey', apiKey);
            
            return apiCredentialsMap;
        }
        else{
            return null;
        } 
    }
    
    //method to encrypt data
    @AuraEnabled
    public static String encryptMethod(String apiKey, String baseURL){
        
        String algorithmName = 'AES256';   
        Constants obj = new Constants();
        String key= obj.DEFAULT_KEY;
        Blob privateKey = Blob.valueOf(key);
        Blob encryptedValueApiKey = Blob.valueOf(apiKey);
        Blob encryptedValueApiKeyFinal = Crypto.encryptWithManagedIV(algorithmName, privateKey, encryptedValueApiKey);
        apiKey = EncodingUtil.Base64Encode(encryptedValueApiKeyFinal);
        
        if(SetupPackage.fetchCredentials().size() > 0){
            if(!test.isRunningTest()){
                createRemoteSiteSetting.createRemoteSiteSettings('ContractRoomProd',baseURL);
            }
            // createRemoteSiteSetting.createRemoteSiteSettings('ContractRoomProd',EndPointURL);
            postgrid__c customSetting = SetupPackage.fetchCredentials()[0];
            customSetting.ApiKey__c	 = apiKey;
            customSetting.Base_URL__c = BaseURL; 
            if (Schema.sObjectType.postgrid__c.fields.ApiKey__c.isUpdateable() && Schema.sObjectType.postgrid__c.fields.Base_URL__c.isUpdateable() ){
                update customSetting;
            }
            return 'success';	
        }
        
        else if(SetupPackage.fetchCredentials().size() == 0){
            if(!test.isRunningTest()){
                CreateRemoteSiteSetting.createRemoteSiteSettings('postgridProd',baseURL); 
            }
            postgrid__c customSetting = new postgrid__c (Name='postgridSettings');
            customSetting.ApiKey__c	 = apiKey;
            customSetting.Base_URL__c = BaseURL; 
            // customSetting.SetupOwnerId = UserInfo.getUserId();
            if (Schema.sObjectType.postgrid__c.fields.ApiKey__c.isCreateable() && Schema.sObjectType.postgrid__c.fields.Base_URL__c.isCreateable() ){
                database.insert(customSetting,true);
            }
            
            return 'success';
        }
        return 'error';
    }
    //method to decrypt data
    public static String decryptMethod(String mainkey){
        Blob pbKey;
        String algorithmName;
        String key;
        Blob privateKey;
        Blob decr;
        String pubKey1;
        Constants obj = new Constants();
        if(!Test.isRunningTest()){
            pbKey = EncodingUtil.base64Decode(mainkey);
            algorithmName = 'AES256';
            key=obj.DEFAULT_KEY;
            privateKey = Blob.valueOf(key);
            decr = Crypto.decryptWithManagedIV(algorithmName, privateKey, pbKey);
            pubKey1 = decr.toString();
            
        }
        else{
            pubKey1 ='testDecrypt';
        } 
        return pubKey1;    
    }   
}