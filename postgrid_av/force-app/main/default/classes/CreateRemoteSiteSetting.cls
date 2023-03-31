public with sharing class CreateRemoteSiteSetting {
    // Method to create remote site settings from meta data API
    @future(callout=true)
    public static void createRemoteSiteSettings(String remoteSiteSettingName , String remoteSiteSettingURL){
        Map<string,string> remoteSiteMap = new Map<string,string>();
        RemoteSiteMap.put(remoteSiteSettingName,URL.getSalesforceBaseUrl().toExternalForm());
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>(); // list stores remote site settings
        for(string remotesite : RemoteSiteMap.keyset()){  // iteration of all remote site
            MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
            remoteSiteDetails.fullName = remotesite;
            remoteSiteDetails.description = 'This is Description';
            remoteSiteDetails.disableProtocolSecurity  = false;
            remoteSiteDetails.isActive  = true;
            remoteSiteDetails.url = remoteSiteSettingURL;
            allMetadataList.add(remoteSiteDetails);
        }        
        if(allMetadataList.size()>0){
            system.debug('RemoteSiteSettings allMetadataList:'+allMetadataList);
            MetadataService.MetadataPort service = createService();
            List<MetadataService.UpsertResult> results = service.upsertMetadata(allMetadataList);  //upsert of remote sites.
            for(MetadataService.UpsertResult result: results){
                    if(result.success){
                        system.debug('added remote site setting success='+result);
                        //isSucessfull=true;
                    }else{
                        system.debug('error while adding remote site settings:'+result.errors[0].message);
                    }

            }

        }
        //return isSucessfull;
    }  
  // metadata Api for create service of remote site
    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
}