public class WebServiceMockImpl implements WebServiceMock {
    public MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            deployOptions.allowMissingFiles = false;
            deployOptions.autoUpdatePackage = false;
            deployOptions.checkOnly = false;
            deployOptions.ignoreWarnings = false;
            deployOptions.performRetrieve = false;
            deployOptions.purgeOnDelete = false;
            deployOptions.rollbackOnError = true;
            deployOptions.testLevel = 'NoTestRun';
            deployOptions.singlePackage = true;
            Map<String, MetadataService.deployResponse_element> responseElement = new Map<String, MetadataService.deployResponse_element>();
            MetadataService.upsertMetadataResponse_element response_x = new MetadataService.upsertMetadataResponse_element();
            MetadataService.UpsertResult result_y = new MetadataService.UpsertResult();
            List<MetadataService.UpsertResult> result_x = new List<MetadataService.UpsertResult>();
            boolean created_x = true;
            string fullName_x='TEST';
            boolean success_x=TRUE;
            result_y.created=created_x;
            result_y.fullName=fullName_x;
            result_y.success=success_x;
            result_x.add(result_y);
            response_x.result = result_x;
            response.put('response_x', (Object)response_x);
        }
}