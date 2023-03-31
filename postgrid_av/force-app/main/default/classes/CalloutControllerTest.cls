@isTest
global class CalloutControllerTest {
    @isTest static void calloutMethodTest(){
        try{
        Test.setMock(HttpCalloutMock.class, new ContractMockClass(200,'{"object":"list","limit":1,"skip":0,"totalCount":19,"data":[{"id":"bank_1j6DJ93wXWzWM13etd3JdM","object":"bank_account","live":false,"accountNumberAndIDSHA256":"Avwlwj2Nvg+cqrVcZFo48RfonpohaYUYhoq07Qd40v4=","accountNumberLast4":"7890","bankCountryCode":"US","bankName":"truffle","bankPrimaryLine":"100 Garden Street","bankSecondaryLine":"Gananoque, ON K7G 1H9","description":null,"routeNumber":null,"routingNumber":"123456789","signatureText":"gunjn","transitNumber":null,"createdAt":"2022-10-27T06:50:09.064Z","updatedAt":"2022-10-27T06:50:09.064Z"}]}'));
        map<string,string> header = new Map<String,string> ();
        header.put('x-api-key','test_sk_8GpXLcdj468DhKBKFH1wtj');
        }
        catch(Exception e){
            system.debug(e);
        }
    }
}