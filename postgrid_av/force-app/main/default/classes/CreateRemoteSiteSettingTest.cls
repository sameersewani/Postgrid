@isTest
public class CreateRemoteSiteSettingTest {
	@isTest
    public static void createRemoteSiteSettingsTest(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        CreateRemoteSiteSetting.createRemoteSiteSettings('ContractRoomProd','https://api.postgrid.com/print-mail/v1/');
        Test.stopTest();
    }
    @isTest
    public static void createServiceTest(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        CreateRemoteSiteSetting.createService();
        Test.stopTest();
    }
}