import { LightningElement,track,wire } from 'lwc';
import getAddressTypeFields from '@salesforce/apex/MultipleAddressVerificationController.getAddressTypeFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/MultipleAddressVerificationController.getData';
import getUpdateValue from '@salesforce/apex/MultipleAddressVerificationController.UpdateValue';
import getCorrectData from '@salesforce/apex/MultipleAddressVerificationController.getCorrectData';
import comboBoxLabel from '@salesforce/label/c.MultipleAddressLabel';
import actualAddressLabel from '@salesforce/label/c.ActualAddressLabel';
import testApiKey from '@salesforce/apex/VerifyAddressController.testApiKey';
import getCrediantials from '@salesforce/apex/CustomSettingGenerateController.getCrediantials';
export default class MultipleAddressVerify extends LightningElement
{
    @track getObject;
    @track apiKey;
    @track baseUrl;
    @track getField;
    @track ShowCancelButton=false;
    @track records = [];
    @track RightIds=[];
    @track ShowDataTable=false;
    @track lstOfAddressFields=[];
    @track dataTableRecord=[]; 
    @track addressToSend=[];
    @track csvAddress=[];
    @track wrongAddressToSend=[];
    @track showSpinner=false;
    @track nextButton=true;
    @track previousButton=true;
    @track lstOfAddress=[];
    @track addressBody='';
    @track totalRecords = 0;
    @track selectAllButton=false;
    @track totalPages; //Total no.of pages
    @track pageNumber = 1; //Page number
    @track pageSize=10; //No.of records to be displayed per page
    @track totalSize=0;
    @track wrongCount=0;
    @track CorrectCount=0;
    @track status='';
    @track rightCount=0;
    @track showSpinnerTwo=false;
    @track isModalOpen=false;
    @track lstOfId=[];
    @track ShowValidateButton=false;
    label = {comboBoxLabel,actualAddressLabel};
    @track selectedRows = [];
    @track currentRows = [];
    @track allSelectedData = [];
    @track csvCorrectArray=[];
    @track csvWrongArray=[];

    headers=
    {
        Id:"Id",
        Address:"Address"
    }


    @track columns=
    [
        { label:'Id', fieldName:'Id'},
        { label:'Name', fieldName:'Name'}
    ];
    get options()
    {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
            { label: 'Lead', value: 'Lead' },
        ];
    }
    connectedCallback()
    {
        console.log('page   ',this.pageNumber);
        if(this.pageNumber==1)
        {
            this.previousButton=false;
            this.nextButton=true;
        }       
        getCrediantials()
        .then(res=>
            {
                console.log('res',res);    
                this.apiKey=res.apiKey;
                this.baseUrl=res.baseURL;
                console.log(this.apiKey);
                console.log(this.baseUrl);
            })
            .catch(error=>
            {
                console.log('Error in getting Address fields',error);
            })  
    }

    onFieldComboBox(event)
    {
       this.dataTableRecord = [];
       this.ShowValidateButton=true;
       this.columns=[{ label:'Id', fieldName:'Id'},{ label:'Name', fieldName:'Name'}];
       this.getField=event.target.value;
       this.columns.push({label:this.getField,fieldName:this.getField});
       this.showSpinner=true;
      
       this.ShowDataTable=true;
       this.ShowDataTableRecord();     
    }

    ShowDataTableRecord()
    {      
        getData({objectName:this.getObject,fieldname:this.getField})
        .then(res=>
        {
            console.log('response -',res);
            if(res.length==0)
            {
                this.showSpinner=false;
                this.selectAllButton=false;
                this.ShowDataTable=false;
                this.totalRecords = res.length;
                this.nextButton=false;
                this.previousButton=false;
                this.ShowValidateButton=false;
            }
            else
            {
                this.records = res;
                this.totalRecords = res.length;
                this.showSpinner=false;
                this.selectAllButton=true;
                var addressData=res;  //Storing the data temporarily    
                console.log('addressData  ',addressData);       
                addressData.forEach(record =>{
                    console.log('rrr'+JSON.stringify(record));
                    if(record.hasOwnProperty(this.getField))
                    {
                        if(record[this.getField].hasOwnProperty('street') && record[this.getField].hasOwnProperty('city') && record[this.getField].hasOwnProperty('state') && record[this.getField].hasOwnProperty('postalCode') && record[this.getField].hasOwnProperty('country'))
                        {
                            
                            record[this.getField]=record[this.getField].street+','+record[this.getField].city+','+record[this.getField].state+','+record[this.getField].postalCode+','+record[this.getField].country;                       
                        }
                        else
                        {
                            let strArr = [];
                            let str='';
                            if(!record[this.getField].hasOwnProperty('street'))
                            {
                                str+= '';
                                this.street='';
                            }
                            else 
                            {
                                strArr.push(record[this.getField].street);
                                this.street=record[this.getField].street;
                                //console.log('street'+this.street);
                            }
    
                            if(!record[this.getField].hasOwnProperty('city'))
                            {
                                str+= '';
                                this.city='';
                            }
                            else 
                            {
                                if(strArr.length >0)
                                {
                                    strArr.push(','+record[this.getField].city);
                                }
                                  
                                else
                                {
                                    strArr.push(record[this.getField].city);
                                    this.city=record[this.getField].city;
                                }                                
                            }
    
                            if(!record[this.getField].hasOwnProperty('state'))
                            {
                                str+= '';
                                this.state='';
                            }
                            else 
                            {
                                if(strArr.length > 0)
                                    strArr.push(','+record[this.getField].state);
                                else
                                {
                                    strArr.push(record[this.getField].state);
                                    this.state=record[this.getField].state;
                                }                               
                            }
    
                            if(!record[this.getField].hasOwnProperty('postalCode'))
                            {
                                str+= '';
                                this.postalcode='';
                            }
                            else 
                            {
                                if(strArr.length >0)
                                    strArr.push(','+record[this.getField].postalCode);
                                else
                                {
                                    strArr.push(record[this.getField].postalCode);
                                    this.postalcode=record[this.getField].postalCode;
                                }
                            }
    
                            if(!record[this.getField].hasOwnProperty('country'))
                            {
                                str+= '';
                                this.country='';
                            }
                            else 
                            {                         
                                if(strArr.length >0)
                                    strArr.push(','+record[this.getField].country);
                                else
                                {
                                    strArr.push(record[this.getField].country);
                                    this.country=record[this.getField].country;
                                }                               
                            }
                            str = '';
                            for(let z=0;z<strArr.length;z++) 
                            {
                                str += strArr[z];
                            }
                            
                            record[this.getField]= str;
                        }
                    }
                 });
                  this.dataTableRecord=addressData;
                  this.paginationHelper();
            }
            
        })
        .catch(error=>
        {
            console.log('Error in getting Records',error);
        })
    }
    onObjectComboBox(event)
    {
        this.pageNumber=1;
        this.connectedCallback();
        this.selectedRows=[];  
        this.ShowCancelButton=false;
        this.selectAllButton=false;
        this.ShowValidateButton=false;
        this.ShowDataTable=false;
        this.getObject=event.target.value;
        console.log(this.getObject);
        getAddressTypeFields({ObjectName:this.getObject})
        .then(res=>
        {
            console.log(res);
            this.lstOfAddressFields = [];
            this.csvCorrectArray=[];
            this.csvWrongArray=[];
            for (let key in res)
            {
               console.log(key);
               this.lstOfAddressFields.push({label: key, value: key });
               //console.log(this.lstOfAddressFields);
            }
           
        })
        .catch(error=>
        {
            console.log('Error in getting Address fields',error);
        })    
    }

    toastNotification(title, message, variant)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);

    }
    getSelectedRecord(event)
    {     
        this.lstOfAddress=[];
        this.addressToSend=[];
        this.csvAddress=[];
        this.wrongAddressToSend=[];
        this.lstOfId=[];      
        const selectedRows = event.detail.selectedRows;
        let selectedIds = [];
        event.target.selectedRows.forEach(row =>
        {
            selectedIds.push(row);
        })
        this.selectedRows[this.pageNumber - 1] = selectedIds;  // index of selectedRows
        this.allSelectedData[this.pageNumber - 1] = selectedRows; // Storing all the selectedRows Address data
        this.currentRows = this.selectedRows[this.pageNumber - 1]; // index of selectedRows
        console.log('selectedRows',this.selectedRows); // index of selectedRows
        console.log('currentRows',this.currentRows);  // index of selectedRows
        console.log('allSelectedData',JSON.parse(JSON.stringify(this.allSelectedData))); // storing data  of selectedRows

        this.allSelectedData.forEach(row =>
            {
                row.forEach(data => 
                {                  
                    if(data[this.getField]!=null)
                    {                      
                        this.lstOfId.push(data.Id);
                        this.lstOfAddress.push(data[this.getField]);
                    }
                })
            });
            
            console.log('lst==',this.lstOfAddress);       
            console.log('Id==',this.lstOfId);
            if(this.lstOfId.length>=1)
            {
                this.template.querySelector('.btn').disabled=false;
                this.ShowCancelButton=true;
            }
            else if(this.lstOfId.length==0)
            {   
                this.template.querySelector('.btn').disabled=true;
                this.ShowCancelButton=false;
            }   
    }
    previousHandler()
    {
        this.pageNumber = this.pageNumber - 1;
        if(this.pageNumber==1)
        {
            this.previousButton=false;
            this.nextButton=true;
        }
        else
        {
            this.nextButton=true;
        }
        this.template.querySelector('lightning-datatable').selectedRows=[];
        this.paginationHelper();
    }
    nextHandler()
    { 
        this.previousButton = true;
        this.pageNumber = this.pageNumber + 1;
        if(this.pageNumber==this.totalPages)
        {
            this.nextButton=false;
        }
        this.template.querySelector('lightning-datatable').selectedRows=[];
        this.paginationHelper();
        
    }
    paginationHelper()
    {
        this.dataTableRecord=[];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if(this.totalPages==1)
        {
            this.nextButton=false;
            this.previousButton=false;
        }
        // set page number
        else if (this.pageNumber <= 1)
        {
            this.pageNumber = 1;
        }
        else if (this.pageNumber >= this.totalPages)
        {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page
          for (let i = (this.pageNumber - 1) *this.pageSize; i<this.pageNumber * this.pageSize; i++)
          {
                if (i === this.totalRecords)
                {
                    break;
                }
                this.dataTableRecord.push(this.records[i]);
          }
          this.currentRows = this.selectedRows[this.pageNumber - 1]; // stores the rows as per page number
          console.log(this.selectedRows, 'selectedRows', this.pageNumber);
    }
    ValidateClick()
    {
        console.log(this.baseUrl);
        testApiKey({apiKey: this.apiKey,baseURL: this.baseUrl})
            .then((result) => 
            {
                console.log(result);
                let res = JSON.parse(JSON.stringify(result)) 
                console.log('message',res.message)
                console.log('status',res.status)
                let check = res.status.toString();
                this.toastNotification('Api Credentials',res.message,res.status);
        
            })
            .catch((error) => 
            {
                let res = JSON.parse(JSON.stringify(error))
                console.log(res);
               // this.toastNotification('Api Credentials', res.body.message, res.status);
                this.toastNotification('Api Credentials', 'Please enter valid credentials', 
                res.status);
            });

        this.status='InProgress';
        this.isModalOpen=true;
        this.showSpinnerTwo=true;
        console.log(JSON.stringify(this.lstOfAddress));
        console.log(JSON.stringify(this.lstOfId));
        getCorrectData({recordIds:this.lstOfId,addressbody:this.lstOfAddress})
        .then(res=>
        {
            console.log(res);
            this.showSpinnerTwo=false;
            this.totalSize=res.totalSize;
            if(this.totalSize!=0)
            {
                this.template.querySelector('.successfulRecordsbtn').disabled=false;
                this.template.querySelector('.errorRecordsbtn').disabled=false;
                this.template.querySelector('.updateRecordbtn').disabled=false;
            }
            if(!res.hasOwnProperty('wrongCount'))
            {
                this.wrongCount=0;
            }
            else
            {
               this.wrongCount=res.wrongCount;
            }
            this.rightCount =res.rightCount;
            this.CorrectCount=res.Sameaddress;
            this.status='Completed';
            this.addressToSend=res.address;
            this.csvAddress=res.Rightaddress;
            this.RightIds=res.RightId;
            console.log('addressToSend',JSON.stringify(this.addressToSend));
            console.log('csvAddress',JSON.stringify(this.csvAddress));
         

            if(this.csvAddress.length>0)
            {
                for(let i=0; i<this.csvAddress.length; i+=3)
                {
                    this.csvCorrectArray.push([this.csvAddress[i],this.csvAddress[i+1],
                        this.csvAddress[i+2]]);
                }
                console.log('csvCorrectArray==',JSON.stringify(this.csvCorrectArray));
            }

            if(res.hasOwnProperty('WrongAddress'))
            {
                this.wrongAddressToSend=res.WrongAddress;
                console.log('wrongAddressToSend',JSON.stringify(this.wrongAddressToSend));
                console.log('WrongAddressLength',this.wrongAddressToSend.length);
                for(let i=0; i<this.wrongAddressToSend.length; i+=3)
                {
                    this.csvWrongArray.push([this.wrongAddressToSend[i],this.wrongAddressToSend[i+1]
                        ,this.wrongAddressToSend[i+2]]);
                }
                console.log('csvWrongArray==',JSON.stringify(this.csvWrongArray));
            }
            
            
        })
        .catch(error=>
        {
            console.log('Error:-',error);
            const event = new ShowToastEvent(
             {
                   title: 'Error!',
                   variant:'error',
                   message:'Address is not validated'
             });
             this.dispatchEvent(event);
             this.showSpinnerTwo=false;
        })
    }
    closeModal()
    {
        this.isModalOpen=false;
        this.status='';
        this.totalSize=0;
        this.rightCount=0;
        this.CorrectCount=0;
        this.wrongCount=0;
        this.template.querySelector('.btn').disabled=true;
        this.lstOfAddress=[];
        this.lstOfId=[];
        this.allSelectedData=[];
        this.template.querySelector('lightning-datatable').selectedRows=[];  
        this.ShowCancelButton=false;   
        this.selectedRows=[];
        this.csvCorrectArray=[];
        this.csvWrongArray=[];
    }
    CancelClick()
    {
        this.ShowCancelButton=false;
        this.template.querySelector('.btn').disabled=true;
        this.lstOfAddress=[];
        this.csvCorrectArray=[];
        this.csvWrongArray=[];
        this.lstOfId=[];
        this.allSelectedData=[];
        this.template.querySelector('lightning-datatable').selectedRows=[];     
        this.selectedRows=[];
    }
    selectAll(event)
    {
        this.template.querySelector('.btn').disabled=false;
       for(let i=0; i<this.totalRecords/this.pageSize; i++)
       {
            let arr=[];
            let arr2=[];
            for(let j=0; j<this.pageSize; j++)
            {
                if(this.totalRecords%this.pageSize!=0 && j<this.totalRecords%this.pageSize
                     && i+1>this.totalRecords/this.pageSize)
                {
                    arr.push('row-'+j);
                    console.log(this.records[i*this.pageSize+j]);
                    arr2.push(this.records[i*this.pageSize+j])
                }
                else if(i+1<=this.totalRecords/this.pageSize)
                {
                    arr.push('row-'+j);
                    console.log(this.records[i*this.pageSize+j]);
                    arr2.push(this.records[i*this.pageSize+j])
                }  
            }
            this.selectedRows[i]=arr;
            this.allSelectedData[i]=arr2;
       }
       //console.log(this.selectedRows);
       this.currentRows=this.selectedRows[this.pageNumber - 1];
       this.lstOfAddress=[];
       this.csvCorrectArray=[];
        this.csvWrongArray=[];
       this.lstOfId=[];
       this.allSelectedData.forEach(row =>
        {
            row.forEach(data => 
            {
                //console.log(JSON.stringify(data[this.getField]));
                if(data[this.getField]!=null)
                {
                    this.lstOfAddress.push(data[this.getField]);
                }
               this.lstOfId.push(data.Id);
            })
        });
        console.log('lst==',this.lstOfAddress);
        this.ShowCancelButton=true;
       
    }
    homeCLick()
    {
        this.isModalOpen=false;
        this.lstOfAddress=[];
        this.csvCorrectArray=[];
        this.csvWrongArray=[];
        this.lstOfId=[];
        this.allSelectedData=[];
        this.template.querySelector('lightning-datatable').selectedRows=[];     
        this.selectedRows=[];
        this.ShowCancelButton=false;
        this.template.querySelector('.btn').disabled=true;

    }
    updateRecordsButton()
    {
        console.log(JSON.stringify(this.lstOfId));
        getUpdateValue({objectName:this.getObject, fieldname:this.getField,
            recordIds:this.RightIds ,Address:this.addressToSend})
         .then(res=>
         {
            console.log('RecordUpdated',res); 
            this.isModalOpen=false;
            this.lstOfAddress=[];
            this.csvCorrectArray=[];
            this.csvWrongArray=[];
            this.lstOfId=[];
            this.allSelectedData=[];
            this.template.querySelector('lightning-datatable').selectedRows=[];     
            this.selectedRows=[];   
            this.template.querySelector('.btn').disabled=true;
            this.ShowCancelButton=false;
            const event = new ShowToastEvent(
                {
                    title: 'Success!',
                    variant:'Success',
                    message:'Address Is Updated'
                });
                this.dispatchEvent(event);
                this.ShowDataTableRecord();
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
    }  

        successfulRecordsButton()
        {
              //define the heading for each row of the data  
                var csv = 'Id,Original Address,Validated Address\n';     
                 
                //merge the data with CSV  
                this.csvCorrectArray.forEach(function(row)
                 {  
                        csv += row.join(',');  
                        csv += "\n";  
                });  
            
                var hiddenElement = document.createElement('a');  
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);  
                hiddenElement.target = '_blank';  
                
                //provide the name for the CSV file to be downloaded  
                hiddenElement.download = 'Correct Address.csv';  
                hiddenElement.click();             
        }

        errorRecordsButton() 
        {
           //define the heading for each row of the data  
           var csv = 'Id,Address,ErrorMessage\n';     
                 
           //merge the data with CSV  
           this.csvWrongArray.forEach(function(row)
            {  
                   csv += row.join(',');  
                   csv += "\n";  
           });  
       
           var hiddenElement = document.createElement('a');  
           hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);  
           hiddenElement.target = '_blank';  
           
           //provide the name for the CSV file to be downloaded  
           hiddenElement.download = 'Wrong Address.csv';  
           hiddenElement.click();                      
        }

}