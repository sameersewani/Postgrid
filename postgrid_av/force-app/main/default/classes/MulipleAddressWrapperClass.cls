//This class in used for creating wrapper class of response

public class MulipleAddressWrapperClass 
{
        public String status;	//success
        public String message;	//Verified international addresses batch successfully.
        public cls_data data;
        public class cls_data 
        {
            public cls_results[] results;
        }
        public class cls_results 
        {
            public cls_verifiedAddress verifiedAddress;
        }
        public class cls_verifiedAddress 
        {
            public String formattedAddress;	//1946 E 113th St,Los Angeles CA 90059-2006
            public String line1;	//1946 E 113th St
            public String line2;	//Los Angeles CA 90059-2006
            public String city;	//Los Angeles
            public String provinceOrState;	//CA
            public String postalOrZip;	//90059-2006
            public String country;	//US
            public cls_summary summary;
            public cls_geoData geoData;
            public cls_details details;
        }
        public class cls_summary
        {
            public String verificationStatus;	//verified
            public String postProcessedVerificationMatchLevel;	//premise_or_building
            public String preProcessedVerificationMatchLevel;	//premise_or_building
            public String parsingStatus;	//identified_and_parsed
            public String lexiconIdentificationMatchLevel;	//premise_or_building
            public String contextIdentificationMatchLevel;	//premise_or_building
            public String postCodeStatus;	//postal_code_primary_verified, postal_code_secondary_added_or_changed
            public Integer matchScore;	//100
            public String message;
        }
        public class cls_geoData 
        {
            public String latitude;	//33.932350
            public String longitude;	//-118.237410
            public String geoAccuracy;	//P4
        }
        public class cls_details 
        {
            public String premise;	//1946
        }
        public static MulipleAddressWrapperClass parse(String json)
        {
            return (MulipleAddressWrapperClass) System.JSON.deserialize(json, MulipleAddressWrapperClass.class);
        }     

}