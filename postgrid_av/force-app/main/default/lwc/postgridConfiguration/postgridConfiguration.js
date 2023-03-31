import { LightningElement, track, wire } from 'lwc';
import encryptMethod from '@salesforce/apex/CustomSettingGenerateController.encryptMethod';
import autoPopulateData from '@salesforce/apex/CustomSettingGenerateController.autoPopulateData';
import testApiKey from '@salesforce/apex/VerifyAddressController.testApiKey';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';

export default class PostgridConfiguration extends NavigationMixin(LightningElement) {
    @track baseURL;
    @track baseURLPrevious;
    @track apiKey;
    apiKeyPrevious;
    secretKey;
    secretKeyPrevious;
    postgridCredentialsMap;
    showComponent
    type1 = "password";
    icon1 = "utility:hide"
    showSubmit = false;
    showData = true;
    viceversa = true;
    editMode = false;
    readOnly = true;
    showSyncBtn = false;

    @track prfName;
    userId = strUserId;
    showPostGrid;

    @wire(getRecord, {
        recordId: strUserId,
        fields: [PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.prfName = data.fields.Profile.value.fields.Name.value;
            this.showComponent = true;
            if (this.prfName == 'System Administrator') {
                this.showPostGrid = true;
            }
            else {
                this.showPostGrid = false;

            }
        }
    }

    connectedCallback() {
        autoPopulateData()
            .then((result) => {

                if (result != null) {
                    this.postgridCredentialsMap = result;
                    console.log('result', result)

                    this.apiKey = this.postgridCredentialsMap['apiKey'];
                    this.apiKeyPrevious = this.postgridCredentialsMap['apiKey'];
                    this.baseURL = this.postgridCredentialsMap['baseURL'];
                    this.baseURLPrevious = this.postgridCredentialsMap['baseURL'];

                    if (this.apiKey != '' || this.apiKey != null && this.baseURL != '' || this.baseURL != null) {
                        this.showSyncBtn = true;
                    }
                }
            })

    }
    setIconType1(type1, icon1) {
        this.type1 = type1;
        this.icon1 = icon1;
    }


    cancelMethod() {
     //   eval("$A.get('e.force:refreshView').fire();");
        this.setIconType1("password", "utility:hide");
        autoPopulateData()
            .then((result) => {
                if (result != null) {
                    this.postgridCredentialsMap = result;
                    this.apiKey = this.postgridCredentialsMap['apiKey'];
                    this.apiKeyPrevious = this.postgridCredentialsMap['apiKey'];
                    this.baseURL = this.postgridCredentialsMap['baseURL'];
                    this.baseURLPrevious = this.postgridCredentialsMap['baseURL'];
                }
            })


        this.showSubmit = false;
        this.editMode = false;
        this.readOnly=true;
    }

    editMethod() {
        this.editMode = true;
        this.readOnly = false;
    }

    apiKeyMethod(event) {
        this.apiKey= event.target.value;
        console.log('apiKey', this.apiKey);
        this.setIconType1("text", "utility:preview");
        this.checkEmptyValue();
    }

    baseUrlMethod(event) {
        this.baseURL = event.target.value;
        console.log('baseURL', this.baseURL);
        this.checkEmptyValue();
    }

    checkEmptyValue(){
        if(this.apiKey != '' || this.baseURL !=''){
            this.showSubmit = true;
        }
        else{
            this.showSubmit = false;
        }
    }

    togglepassword1() {
        if (this.type1 == "password") {
            this.setIconType1("text", "utility:preview");
        }
        else {
            this.setIconType1("password", "utility:hide");
        }
    }

    checkApiKey(){
        testApiKey({
            apiKey: this.apiKey,
            baseURL: this.baseURL
        })
            .then((result) => {
                console.log(result);
                let res = JSON.parse(JSON.stringify(result)) 
                console.log('message',res.message)
                console.log('status',res.status)
                let check = res.status.toString();
                this.toastNotification('Api Credentials',res.message,res.status);
                if(check == 'success'){
                    console.log('in check');
                    this.callout();
                }    
                else{
                    this.cancelMethod();

                }    
                this.setIconType1("password", "utility:hide");
        
            })
            .catch((error) => {
                let res = JSON.parse(JSON.stringify(error))
               // this.toastNotification('Api Credentials', res.body.message, res.status);
                this.toastNotification('Api Credentials', 'Please enter valid credentials', res.status);
                this.apiKey = '';
                this.baseURL='';
                this.cancelMethod();
                //console.log(error);
            });
    }

    callout() {
        if(this.apiKey != null || this.apiKey != '' && this.baseURL != null || this.baseURL != ''){
            this.apiKey = this.apiKey.trim();
        this.baseURL = this.baseURL.trim();
        encryptMethod({
            apiKey: this.apiKey,
            baseURL: this.baseURL
        })
            .then((result) => {
                console.log(result);

                this.toastNotification('Custom Setting Component','Sucessfully Created Record','success');
            })
            .catch((error) => {
                console.log(error);
            });

        }else{
            this.toastNotification('Custom Setting Component', 'There is error in Api Credentials','error');
        }
        

    }

    toastNotification(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);

    }

    startMethod() {
        this.editMode = false;
        this.readOnly = true;
        this.showSubmit = false;
        this.checkApiKey();
    }
}