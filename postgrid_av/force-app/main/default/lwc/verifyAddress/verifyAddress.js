import { LightningElement,api, track,wire } from 'lwc';
import getAddressTypeFields from '@salesforce/apex/VerifyAddressController.getAddressTypeFields';
import getFieldValue from '@salesforce/apex/VerifyAddressController.getFieldValue';
import fetchapi from '@salesforce/apex/VerifyAddressController.fetchapi';
import getUpdateValue from '@salesforce/apex/VerifyAddressController.UpdateValue';
import myResource from '@salesforce/resourceUrl/Arrow';
import comboBoxLabel from '@salesforce/label/c.ComboBoxLabel';
import actualAddressLabel from '@salesforce/label/c.ActualAddressLabel';
import updatedAddressLabel from '@salesforce/label/c.UpdatedAddressValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';

export default class VerifyAddress extends NavigationMixin (LightningElement)
 {
   
    @api recordId;
    @api objectApiName;
    @track lstOfAddressFields=[];   
    @track fieldname='';
    @track actualAddress='';
    @track updatedAddress='';
    @track map1 = new Map();
    @track city;
    @track country;
    @track street;
    @track postalcode;
    @track state;
    @track doubleArrow=myResource;
    @track showValidateButton=true;
    @track demoAddress='';
    @track showSpinner=false;
    
     label = {comboBoxLabel,actualAddressLabel,updatedAddressLabel};

    @wire(getAddressTypeFields,{strObjectName: '$objectApiName'})
      wiredAddress({ error, data }) 
       {
          if(data)
         {
            console.log(data);
            this.lstOfAddressFields = [];
            for (let key in data) 
            {
               console.log(key);
               this.lstOfAddressFields.push({label: key, value: key });
               console.log(this.lstOfAddressFields);
            }
          } 
          else if (error)
          {
            console.log('Error in getting Address fields',error);
          }
       }

        onComboBoxChange(event)
       {
         this.template.querySelector('.btnvalidate').disabled=false;
         this.showSpinner=true;
         this.updatedAddress='';
         this.showValidateButton=true;
         this.fieldname=event.target.value;
         console.log(this.fieldname);
         console.log(this.objectApiName);
         console.log(this.recordId);

         getFieldValue({objectName:this.objectApiName, fieldname:this.fieldname, recordId:this.recordId})
         .then(res=>
         {
             console.log(res);
             this.actualAddress=res;
             this.showSpinner=false;
         })
         .catch(error=>
         {
            this.showSpinner=true;
               console.log('error '+error);
               this.actualAddress='';
               if(this.actualAddress=='')
               {
                  this.showSpinner=true;
                  const event = new ShowToastEvent(
                     {
                        title: 'Error!',
                        variant:'error',
                        message:'Actual Address is Empty'
                     });
                     this.dispatchEvent(event);
                     this.showSpinner=false;
               }
         })
         
      }
      validateClick()
      {
         this.template.querySelector('.btn').disabled=false;
         this.template.querySelector('.btnvalidate').disabled=true;
         if(this.updatedAddress=='' || this.updatedAddress!='')
         {
            this.showSpinner=true;
         }
         if(this.actualAddress=='')
         {
            const event = new ShowToastEvent(
               {
                  title: 'Error!',
                  variant:'error',
                  message:'Actual Address is Empty'
               });
               this.dispatchEvent(event);
               this.showSpinner=false;
         }
         if(this.actualAddress!='')
         {
            fetchapi({address:this.actualAddress})
            .then(response=>
            {
               console.log('res  '+JSON.stringify(response));
               this.map1=response;
               console.log('map1'+this.map1.verificationStatus);
               if(this.map1.error)
               {
                  const event = new ShowToastEvent(
                     {
                        title: 'Error!',
                        variant:'error',
                        message:this.map1.verificationStatus
                  });
                  this.dispatchEvent(event);
                  this.showSpinner=false;
                  this.updatedAddress='';
               }
              
               else
               {
                  this.showSpinner=false;
                  this.street=this.map1.line1;
                  this.city=this.map1.city;
                  this.state=this.map1.provinceOrState;
                  this.postalcode=this.map1.postalOrZip;
                  this.country=this.map1.country;
                  this.updatedAddress=this.map1.line1+','+this.map1.city+','+this.map1.provinceOrState
                    +','+this.map1.postalOrZip+','+this.map1.country;
                  

                    if(this.actualAddress==this.updatedAddress)
                    {
                     const event = new ShowToastEvent(
                        {
                              title: 'Success!',
                              variant:'success',
                              message: 'Address is: '+this.map1.verificationStatus
                        });
                        this.dispatchEvent(event);
                    }
                     else
                     {
                        const event = new ShowToastEvent(
                           {
                                 title: 'Success!',
                                 variant:'success',
                                 message:'Address is: '+this.map1.verificationStatus
                           });
                           this.dispatchEvent(event);
                     }    
               }
            })
            .catch(error=>
               {
                     console.log(error);
                     const event = new ShowToastEvent(
                        {
                           title: 'Error!',
                           variant:'error',
                           message:'Address Is Not Validated'
                     });
                     this.dispatchEvent(event);
                     this.showSpinner=false;
               })
         }
        
      } 
      
      updateRecordView(recordId) 
      {
         updateRecord({fields: { Id:recordId  }});
      }
      
      updateAddress()
      {
         if(this.updatedAddress!='')
         {
            getUpdateValue({objectName:this.objectApiName, fieldname:this.fieldname,
               recordId:this.recordId,Street:this.street,City:this.city,State:this.state,Postalcode:this.postalcode,Country:this.country})
            .then(res=>
            {
               console.log('record ',res);        
            })
            .catch(error=>
            {
                  console.log(error);
                  const event = new ShowToastEvent(
                     {
                        title: 'Error!',
                        variant:'error',
                        message:'Their is Some Error in Address'
                     });
                     this.dispatchEvent(event);
            })
            const event = new ShowToastEvent(
            {
               title: 'Success!',
               variant:'success',
               message:'Record has been successfully updated'
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.updateRecordView(this.recordId);
         }
         else if (this.updatedAddress=='')
         {
            const event = new ShowToastEvent(
               {
                  title: 'Error!',
                  variant:'error',
                  message:'Updated Field is Empty'
               });
               this.dispatchEvent(event);
         }            
         
      }
        
      cancelClick()
      {
         this.dispatchEvent(new CloseActionScreenEvent());
      }
      actualAddressChange(event)
      {
        // this.showValidateButton=true;
         this.template.querySelector('.btnvalidate').disabled=false;
         this.actualAddress=event.target.value;
         console.log(this.actualAddress);
      }
      updatedAddressChange(event)
      {
         this.updatedAddress=event.target.value; 
      }

 }