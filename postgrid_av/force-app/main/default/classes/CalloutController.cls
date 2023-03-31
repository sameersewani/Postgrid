public class CalloutController {
    
    // This method is used for Callout
	public static HttpResponse calloutMethod(string endPointURL, string method, map<string,string> headers, string body, boolean hasHeaders, boolean hasBody){ 
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(endPointURL);
        request.setMethod(method);
        if(hasHeaders == true){
            for(string header : headers.keySet()){
                request.setHeader(header, headers.get(header));       
        	}   
        }
        if(hasBody == true){
            request.setBody(body);
        }
        HttpResponse response = new HttpResponse();
       
        	response = http.send(request);  
 
    
        
        return response;
    }
}