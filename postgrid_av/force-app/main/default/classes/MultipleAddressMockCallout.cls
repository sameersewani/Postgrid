@isTest
global class MultipleAddressMockCallout implements HttpCalloutMock
{
	//Implement this interface method
	global HTTPResponse respond(HTTPRequest request)
    {
    	string fullJson = '';
    	// Create a fake response
    	if (request.getEndpoint().endsWith('intl_addver/verifications/batch?geoData=true&includeDetails=true')) 
        {
        	fullJson = '{"status": "success","message": "Verified international addresses batch successfully.","data": {"results": [{"verifiedAddress": { "formattedAddress": "1946 E 113th St,Los Angeles CA 90059-2006","line1": "1946 E 113th St","line2": "Los Angeles CA 90059-2006","city": "Los Angeles","provinceOrState": "CA","postalOrZip": "90059-2006","country": "US", "summary": { "verificationStatus": "verified","postProcessedVerificationMatchLevel": "premise_or_building","preProcessedVerificationMatchLevel": "premise_or_building","parsingStatus": "identified_and_parsed","lexiconIdentificationMatchLevel": "premise_or_building","contextIdentificationMatchLevel": "premise_or_building","postCodeStatus": "postal_code_primary_verified, postal_code_secondary_added_or_changed","matchScore": 100},"geoData": { "latitude": "33.932350","longitude": "-118.237410","geoAccuracy": "P4"},"details": {"premise": "1946" }}},{"verifiedAddress": {"formattedAddress": "1,K2,Ajay Nagar,Ajmer Rajasthan 305003","line1": "1", "line2": "K2","line3": "Ajay Nagar","line4": "Ajmer Rajasthan 305003","city": "Ajmer","provinceOrState": "Rajasthan", "postalOrZip": "305003", "country": "IN","summary": {"verificationStatus": "verified","postProcessedVerificationMatchLevel": "city","preProcessedVerificationMatchLevel": "city","parsingStatus": "identified_and_parsed","lexiconIdentificationMatchLevel": "city","contextIdentificationMatchLevel": "city","postCodeStatus": "postal_code_primary_added","matchScore": 100},"geoData": {  "latitude": "26.420004", "longitude": "74.633256",   "geoAccuracy": "A2" },"details": {  "subBuilding": "1",  "premise": "K2" }} }] }}';
        }
    
    	HTTPResponse response = new HTTPResponse();
    	response.setBody(fullJson);
    	response.setHeader('Content-Type', 'application/json');
    	response.setStatusCode(200);
    
    	return response;
    
	}
}