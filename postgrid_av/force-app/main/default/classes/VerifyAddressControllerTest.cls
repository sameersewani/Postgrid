@isTest
public class VerifyAddressControllerTest
{
    @testSetup
    public static void dummyData()
    {
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
    public static void 	AddressTest()
    {
        Test.setMock(HttpCalloutMock.class, new VerifyaAddressMockCallout());
        
        Account a=[select id,name,BillingAddress from account Limit 1];
        Account accountRecord=[select id,name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry from account Limit 1];
        Contact contactRecord=[select id,Lastname,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry from contact Limit 1];
        Lead leadRecrod=[select id,name,Street,City,State,PostalCode,Country from lead Limit 1];
        
        List<VerifyAddressController.recordInput> input = new List<VerifyAddressController.recordInput>();
        
        VerifyAddressController.recordInput pscr = new VerifyAddressController.recordInput();
        pscr.objectName = 'Account';
        pscr.fieldName = 'BillingAddress';
        pscr.recordId = a.Id;
        pscr.Street = '3023 Hemlock';
        pscr.City = 'Ln';
        pscr.State = 'Mcallen';
        pscr.Postalcode = '78501';
        pscr.Country = 'USA';
        input.add(pscr);
        
        
        Test.startTest();
        
        VerifyAddressController.verifyAddress(input);
        VerifyAddressController.fetchapi('1 k2 ajay nagar,ajmer,rajasthan,india');
        VerifyAddressController.testApiKey('live_sk_3DpszjGpcTgpEJ6wZwVLFP','https://api.postgrid.com/v1/');    
        VerifyAddressController.getFieldValue('Account','BillingAddress',a.Id);
        VerifyAddressController.getAddressTypeFields('Account');     
        VerifyAddressController.UpdateValue('Account','BillingAddress',accountRecord.Id ,accountRecord.BillingStreet ,accountRecord.BillingCity ,accountRecord.BillingState ,accountRecord.BillingPostalCode ,accountRecord.BillingCountry);
        VerifyAddressController.UpdateValue('Account','ShippingAddress',accountRecord.Id,accountRecord.ShippingStreet,accountRecord.ShippingCity,accountRecord.ShippingState,accountRecord.ShippingPostalCode,accountRecord.ShippingCountry);
        VerifyAddressController.UpdateValue('Contact','MailingAddress',contactRecord.Id ,contactRecord.MailingStreet ,contactRecord.MailingCity ,contactRecord.MailingState ,contactRecord.MailingPostalCode ,contactRecord.MailingCountry);
        VerifyAddressController.UpdateValue('Contact','OtherAddress',contactRecord.Id ,contactRecord.OtherStreet ,contactRecord.OtherCity ,contactRecord.OtherState ,contactRecord.OtherPostalCode ,contactRecord.OtherCountry);
        VerifyAddressController.UpdateValue('Lead','Address',leadRecrod.Id ,leadRecrod.Street ,leadRecrod.City ,leadRecrod.State ,leadRecrod.PostalCode ,leadRecrod.Country);
           
        Test.stopTest();
    }
    
}