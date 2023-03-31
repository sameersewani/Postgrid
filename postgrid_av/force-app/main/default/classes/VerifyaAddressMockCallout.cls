@isTest
global class VerifyaAddressMockCallout implements HttpCalloutMock
{

	//Implement this interface method
	global HTTPResponse respond(HTTPRequest request)
    {
    	string fullJson = '';
    	// Create a fake response
    	if (request.getEndpoint().endsWith('intl_addver/verifications?includeDetails=true') ) 
        {
        	fullJson = '{"status": "success","message": "International address verified successfully.","data": {"city": "Ajmer","country": "IN","details": {"subBuilding": "1","premise": "K2"},"formattedAddress": "1,K2,Ajay Nagar,Ajmer Rajasthan 305003","geoData": false,"line1": "1","line2": "K2","line3": "Ajay Nagar","line4": "Ajmer Rajasthan 305003","postalOrZip": "305003","provinceOrState": "Rajasthan","summary": {"verificationStatus": "verified","postProcessedVerificationMatchLevel": "city","preProcessedVerificationMatchLevel": "city","parsingStatus": "identified_and_parsed","lexiconIdentificationMatchLevel": "city","contextIdentificationMatchLevel": "city","postCodeStatus": "postal_code_primary_added","matchScore": 100 }  }}';
        }
        else if (request.getEndpoint().endsWith('intl_addver/verifications?includeDetails=true') && request.getBody() =='22-20 bay st, floor 11, toronto, on') 
        {
        	fullJson = '{"status": "success","message": "International address verified successfully.","data": {"country": "ST","details": {},"formattedAddress": "22-20 Bay St, Floor 11, Toronto, On","geoData": false,"summary": {"verificationStatus": "unverified", "postProcessedVerificationMatchLevel": "none","preProcessedVerificationMatchLevel": "none","parsingStatus": "unable_to_parse","lexiconIdentificationMatchLevel": "none","contextIdentificationMatchLevel": "none","postCodeStatus": "postal_code_primary_empty","matchScore": 0}}}';
        }
    
    	HTTPResponse response = new HTTPResponse();
    	response.setBody(fullJson);
    	response.setHeader('Content-Type', 'application/json');
    	response.setStatusCode(200);
    
    	return response;
    
	}
}