@isTest
public class MultipleAddressVerificationTest 
{ 
    @testSetup
    public static void dummyData()
    {
        //Create Account
        Account dummyAccount = new Account();
        dummyAccount.Name='TestData';
        dummyAccount.BillingStreet='1k2 ajay nagar';
        dummyAccount.BillingCity='ajmer';
        dummyAccount.BillingState='Rajasthan';
        dummyAccount.BillingPostalCode='305001';
        dummyAccount.BillingCountry='India';

        dummyAccount.ShippingStreet='1k2 ajay nagar';
        dummyAccount.ShippingCity='ajmer';
        dummyAccount.ShippingState='Rajasthan';
        dummyAccount.ShippingPostalCode='305001';
        dummyAccount.ShippingCountry='India';
        insert dummyAccount; 
        
        //Create Contact
        Contact dummyContact = new Contact();
        dummyContact.LastName='TestData';
        dummyContact.MailingStreet='1k2 ajay nagar';
        dummyContact.MailingCity='ajmer';
        dummyContact.MailingState='Rajasthan';
        dummyContact.MailingPostalCode='305001';
        dummyContact.MailingCountry='India';
        
        dummyContact.OtherStreet='1k2 ajay nagar';
        dummyContact.OtherCity='ajmer';
        dummyContact.OtherState='Rajasthan';
        dummyContact.OtherPostalCode='305001';
        dummyContact.OtherCountry='India';
        insert dummyContact;
        
        //Create Lead
        Lead dummyLead = new Lead();
        dummyLead.LastName='TestData';
        dummyLead.Company='Cyntexa';
        dummyLead.Status='Open - Not Contacted';
        dummyLead.Street='1k2 ajay nagar';
        dummyLead.City='ajmer';
        dummyLead.State='Rajasthan';
        dummyLead.PostalCode='305001';
        dummyLead.Country='India';
        insert dummyLead;
    
        PostGrid_AV__postgrid__c customSetting = new PostGrid_AV__postgrid__c();        
        customSetting.PostGrid_AV__Base_URL__c = 'https://api.postgrid.com/v1/';        
        customSetting.PostGrid_AV__ApiKey__c = 'live_sk_3DpszjGpcTgpEJ6wZwVLFP';
        insert customSetting;
        
    }
    @isTest 
    public static void 	MultpleAddressTest()
    {
        Account accountRecord=[select id,name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry from account Limit 1];
        Contact contactRecord=[select id,Lastname,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry from contact Limit 1];
        Lead leadRecord=[select id,name,Street,City,State,PostalCode,Country from lead Limit 1];
        
        Test.setMock(HttpCalloutMock.class, new MultipleAddressMockCallout());
        
        Test.startTest();
        
        MultipleAddressVerificationController.getAddressTypeFields('Account');
        MultipleAddressVerificationController.getData('Account','BillingAddress');
        MultipleAddressVerificationController.getCorrectData(new List<String>{accountRecord.Id} ,new List<String>{'1946 E 113th St, Los Angeles, CA 90059, USA','1 k2 ajay nagar,ajmer,rajasthan,india'});
        MultipleAddressVerificationController.UpdateValue('Account','BillingAddress',new List<String>{accountRecord.Id} ,new List<String>{accountRecord.Id,'1946 E 113th, St, Los Angeles, CA, 90059',accountRecord.Id,'null,null,null,null,US'});
        MultipleAddressVerificationController.UpdateValue('Account','ShippingAddress',new List<String>{accountRecord.Id} ,new List<String>{accountRecord.Id,'1946 E 113th, St, Los Angeles, CA, 90059',accountRecord.Id,'null,null,null,null,US'});
        MultipleAddressVerificationController.UpdateValue('Contact','MailingAddress',new List<String>{contactRecord.Id} ,new List<String>{contactRecord.Id,'1946 E 113th, St, Los Angeles, CA, 90059',contactRecord.Id,'null,null,null,null,US'});
        MultipleAddressVerificationController.UpdateValue('Contact','OtherAddress',new List<String>{contactRecord.Id} ,new List<String>{contactRecord.Id,'1946 E 113th, St, Los Angeles, CA, 90059',contactRecord.Id,'null,null,null,null,US'});
        MultipleAddressVerificationController.UpdateValue('Lead','Address',new List<String>{leadRecord.Id} ,new List<String>{leadRecord.Id,'1946 E 113th, St, Los Angeles, CA, 90059',leadRecord.Id,'null,null,null,null,US'});
        Test.stopTest();
    }
}