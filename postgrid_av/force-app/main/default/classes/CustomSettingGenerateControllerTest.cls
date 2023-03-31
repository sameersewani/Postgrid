@isTest
public class CustomSettingGenerateControllerTest {
  @isTest
    public static void autoPopulateDataTest(){
        PostGrid_AV__postgrid__c pmAcc = new PostGrid_AV__postgrid__c();
        pmAcc.PostGrid_AV__ApiKey__c='pWaF6QurtkM2vcmZNb2+gS17KnoFq7qb4YloDd7TAJ4=';
        pmAcc.PostGrid_AV__Base_URL__c = 'https://api.postgrid.com/print-mail/v1/';
        insert pmAcc;
        String apiKey = customSettingGenerateController.decryptMethod(pmAcc.PostGrid_AV__ApiKey__c);
        CustomSettingGenerateController.autoPopulateData();
    }
    @isTest
    //Test for if condition
    public static void encryptMethodTestOne(){
       String apiKey = 'test_sk_8GpXLcdj468DhKBKFH1wtj';
       String baseUrl = 'https://api.postgrid.com/print-mail/v1/';
       /*PostGrid_AV__postgrid__c pmAcc = new PostGrid_AV__postgrid__c();
       pmAcc.PostGrid_AV__ApiKey__c='pWaF6QurtkM2vcmZNb2+gS17KnoFq7qb4YloDd7TAJ4=';
       pmAcc.PostGrid_AV__Base_URL__c = 'https://api.postgrid.com/print-mail/v1/';
       insert pmAcc;*/
       //createRemoteSiteSetting.createRemoteSiteSettings('ContractRoomProd',baseURL);
       CustomSettingGenerateController.encryptMethod(apiKey,baseUrl);
    }
    //Test for else if condition
    @isTest
    //Test for if condition
    public static void encryptMethodTestTwo(){
       String apiKey = 'test_sk_8GpXLcdj468DhKBKFH1wtj';
       String baseUrl = 'https://api.postgrid.com/print-mail/v1/';
       PostGrid_AV__postgrid__c pmAcc = new PostGrid_AV__postgrid__c();
       pmAcc.PostGrid_AV__ApiKey__c='pWaF6QurtkM2vcmZNb2+gS17KnoFq7qb4YloDd7TAJ4=';
       pmAcc.PostGrid_AV__Base_URL__c = 'https://api.postgrid.com/print-mail/v1/';
       insert pmAcc;
       //createRemoteSiteSetting.createRemoteSiteSettings('ContractRoomProd',baseURL);
       CustomSettingGenerateController.encryptMethod(apiKey,baseUrl);
    }
    @isTest
    public static void decryptMethodTest(){
        String mKey = 'pWaF6QurtkM2vcmZNb2+gS17KnoFq7qb4YloDd7TAJ4=';
        CustomSettingGenerateController.decryptMethod(mKey);
    }
}