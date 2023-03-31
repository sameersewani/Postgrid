@isTest
public class ContractMockClass implements HttpCalloutMock {
    
    public static integer statusCode;
    public static String response;
    public ContractMockClass(Integer code, String res){
        try{
            statusCode = code;
            response = res;
        }
        catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    //Implement this interface method
    public HTTPResponse respond(HTTPRequest request){
        // Create a fake response
        HTTPResponse res = new HTTPResponse();
        res.setBody(response);
        res.setStatusCode(statusCode);
        return res;
    }
}