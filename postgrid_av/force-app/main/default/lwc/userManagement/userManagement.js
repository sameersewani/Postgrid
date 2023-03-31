import { LightningElement, track } from 'lwc';
import fetchUsers from '@salesforce/apex/UserManagementController.fetchUsers';
import ActivateUsersPermissions from '@salesforce/apex/UserManagementController.ActivateUsersPermissions';
import DeactivateUsersPermissions from '@salesforce/apex/UserManagementController.DeactivateUsersPermissions';
import ErrorMessages from '@salesforce/apex/UserManagementController.ErrorMessages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'User Name', fieldName: 'Name' },
    { label: 'Profile Name', fieldName: 'Profile Name' },
    { label: 'Activation Date', fieldName: 'Activation Date', type: 'date-local' },
    { label: 'Active', cellAttributes: { iconName: { fieldName: 'Active' } } },
];
const columns1 = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Id', fieldName: 'id' }
];
export default class UserManagement extends LightningElement {
    EditStrict = false;
    startDate;
    endDate;
    Radiodisabled = false;
    columns = columns;
    @track data = [];
    value1 = 'All';
    value;
    filterValue;
    @track checked = '';
    previous_checked = '';
    searchKey;
    filterValue;
    Users = [];
    UserSize = [];
    wholeList = [];
    rowsSelected = [];
    deactivate = false;
    activate = false;
    customSettingName;
    ErrorMessageActivate;
    ErrorMessageDeactivate;
    AllUsers;
    disabledUserButtons;
    @track selection = [];
    pagination;
    norowsinpage = 15;
    checkOnLoad;


    //Pagination Valiables
    count = 1;
    from;
    to;
    LessThan = false;
    MoreThan = true;
    sizeLessThanFive = false;
    lastPage;
    dotdotfront = false;
    dotdotend = true;
    rowsinpage = 15;
    changeRadio = false;


    connectedCallback() {
        this.setDisable(true);
        ErrorMessages()
            .then((result) => {
                let ErrorMessages = result.split(",");
                this.ErrorMessageActivate = ErrorMessages[1];
                this.ErrorMessageDeactivate = ErrorMessages[0];
            })
            .catch((error) => {
                console.log('Fetching Error Message Error', error);
            })

        this.fetchUser('','')       

        
    }
    renderedCallback() {
        
        this.template.querySelectorAll('.paginationClass').forEach(element => {
            if (element.innerHTML == this.count) {
                element.style.border = '1px solid #0176d3';
                element.style.color = 'white'
                element.style.backgroundColor = 'rgb(1,118,211)'
            } else {
                element.style.border = '0px';
                element.style.color = 'black'
                element.style.backgroundColor = 'white'
            }
        });
        if ((this.wholeList.length) / this.rowsinpage < 7) {
            this.sizeLessThanFive = true;
        } else {
            this.sizeLessThanFive = false;
        }

        this.lastPage = Math.ceil((this.wholeList.length) / this.rowsinpage);

        if (this.count > 1) {
            this.LessThan = true;
        } else {
            this.LessThan = false;
        }
        if (this.count == this.lastPage) {
            this.dotdotend = false;
            this.MoreThan = false;
        } else {
            this.MoreThan = true;
        }
        if (this.count > 4) {
            this.dotdotfront = true;
        } else {
            this.dotdotfront = false;
        }
        if (this.count >= this.lastPage - 4) {
            this.dotdotend = false;
        } else {
            this.dotdotend = true;
        }
        if(this.data.length>0){
            this.pagination  = true;
        }else{
            this.pagination = false;
        }

    }

    //User Table filter values
    get options1() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Active Users', value: 'Active' },
            { label: 'Inactive Users', value: 'Inactive' },
        ];
    }
    get numberOfrows() {
        return [
            { label: '15', value: '15' },
            { label: '25', value: '25' },
            { label: '50', value: '50' },
            { label: 'All', value: 'All' }
        ];
    }

    onStartDate(event) {
        var checkstartDate = event.detail.value;
        if(checkstartDate > this.endDate){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Start Date is greater than End Date',
                variant: 'error'
            });
            this.dispatchEvent(evt);

        }
        else{
            this.startDate = event.detail.value;
        }
    }
    onEndDate(event) {
        var checkEndDate = event.detail.value;
        if(checkEndDate < this.startDate){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'End Date is less than Start Date',
                variant: 'error'
            });
            this.dispatchEvent(evt);

        }
        else{
            this.endDate = event.detail.value;
        }
       
    }
    handleonrowselection(event) {
        const selectedRows = [...event.target.selectedRows];    
        this.Users.forEach(users => {
            if(this.selection.includes(users.Id)){
                this.selection.splice(this.selection.indexOf(users.Id),1);
            }
        });
        selectedRows.forEach(element => {
            if(!this.selection.includes(element)){
                this.selection.push(element);
            }
        });
        this.selection = [...this.selection];

        var buttonFlag = false;
                if(this.Users.length == 0){
                        buttonFlag = true;
                    }else{
                        for(let i = 0 ; i<this.Users.length;i++){
                            if(!this.selection.includes(this.Users[i].Id)){
                                buttonFlag = true;
                                //break;
                            }
                            else{
                                buttonFlag = false;
                                break;
                            }
                        }
                    }
                    
                setTimeout(() => {
                    this.setDisable(buttonFlag);
                }, 0)
    }

    handleChangeFilter(event) {
        this.count=1;
        this.filterValue = event.target.value;
        this.fetchUser(event.target.value, this.searchKey);
        
    }

    searchValue(event) {
        this.searchKey = event.target.value;
        this.UserSize = [];
        this.fetchUser(this.filterValue, this.searchKey);
        
    }
    setDisable(value){
        this.disabledUserButtons = null;
        this.disabledUserButtons = value;
    }
    fetchUser(filterValue, searchKey) {
        this.Users = [];
        this.wholeList = [];

        fetchUsers({ filterValue: filterValue, searchKey: searchKey })
        .then((result) => {
                var temp = [...result];
                var userData = [];
                var obj;

                temp.forEach(user => {
                    if (user.Profile != null) {
                        obj = {
                            'Name': user.Name,
                            'Profile Name': user.Profile.Name,
                            'Activation Date': user.PostGrid_AV__Activation_Date__c,
                            'Active': user.PostGrid_AV__Permission_Set_Checkbox__c ? 'utility:check' : '',
                            'Id': user.Id 
                        };
                    } else {
                        obj = {
                            'Name': user.Name,
                            'Activation Date': user.PostGrid_AV__Activation_Date__c,
                            'Active': user.PostGrid_AV__Permission_Set_Checkbox__c ? 'utility:check' : '',
                            'Id': user.Id
                        };
                    }
                    userData.push(obj);
                });
                this.wholeList = userData;

                if(this.norowsinpage == 'All'){
                    this.rowsinpage = this.wholeList.length;
                }else{
                    this.rowsinpage = parseInt(this.norowsinpage);
                }

                this.Users = this.wholeList.slice(0, this.rowsinpage);
                this.data = this.Users;
                var buttonFlag = false;
                if(this.Users.length == 0){
                        buttonFlag = true;
                    }else{
                        for(let i = 0 ; i<this.Users.length;i++){
                            if(!this.selection.includes(this.Users[i].Id)){
                                buttonFlag = true;
                                //break;
                            }
                            else{
                                buttonFlag = false;
                                break;
                            }
                        }
                    }
                    
                setTimeout(() => {
                    this.setDisable(buttonFlag);
                }, 0)
                
                var length = Math.ceil(this.wholeList.length / this.rowsinpage);
                return length;
            })
            .then((length) => {

                this.UserSize = [];
                if (length < 7) {

                    for (let i = 1; i <= length; i++) {
                        let x = { Count: i };
                        this.UserSize.push(x);
                    }
                }
                else {
                    if (this.count < 5) {

                        for (let i = 2; i <= 6; i++) {
                            let x = { Count: i };
                            this.UserSize.push(x);
                        }
                    }
                    else {
                        if (this.count > length - 5) {
                            for (let i = length - 5; i < length; i++) {
                                let x = { Count: i };
                                this.UserSize.push(x);
                            }
                        }
                        else {
                            for (let i = this.count - 2; i <= this.count + 2; i++) {
                                let x = { Count: i };
                                this.UserSize.push(x);
                            }
                        }
                    }
                }
                this.selection = [...this.selection];
            })
            .catch((error) => {
                console.log('Fetch User Error', error);
            })
    }

    buttonClick(event) {
        this.to = 0;
        this.from = 0;
        this.Users = [];
        this.UserSize = [];
        var length = Math.ceil(this.wholeList.length / this.rowsinpage);

        if (event.target.innerText == '<') {
            this.count -= 1;
            this.to = this.count * this.rowsinpage;
            this.from = this.to - this.rowsinpage;
            this.Users = this.wholeList.slice(this.from, this.to);
        }
        else if (event.target.innerText == '>') {
            this.count = this.count + 1;
            this.to = (this.count) * this.rowsinpage;
            this.from = this.to - this.rowsinpage;
            if (this.to > this.wholeList.length) {
                this.Users = this.wholeList.slice(this.from, this.wholeList.length);
            } else {
                this.Users = this.wholeList.slice(this.from, this.to);
            }
        }
        else {
            this.count = parseInt(event.target.innerText);
            this.to = (this.count) * this.rowsinpage;
            this.from = this.to - this.rowsinpage;
            if (this.to > this.wholeList.length) {
                this.Users = this.wholeList.slice(this.from, this.wholeList.length);
            } else {
                this.Users = this.wholeList.slice(this.from, this.to);
            }
        }



        if (length < 7) {
            for (let i = 1; i <= length; i++) {
                let x = { Count: i };
                this.UserSize.push(x);
            }
        }
        else {
            if (this.count < 5) {
                for (let i = 2; i <= 6; i++) {
                    let x = { Count: i };
                    this.UserSize.push(x);
                }
            } else {
                if (this.count > length - 5) {
                    for (let i = length - 5; i < length; i++) {
                        let x = { Count: i };
                        this.UserSize.push(x);
                    }
                }
                else {
                    for (let i = this.count - 2; i <= this.count + 2; i++) {
                        let x = { Count: i };
                        this.UserSize.push(x);
                    }
                }
            }
        }

        this.data = this.Users;

        var buttonFlag = false;
                if(this.Users.length == 0){
                        buttonFlag = true;
                    }else{
                        for(let i = 0 ; i<this.Users.length;i++){
                            if(!this.selection.includes(this.Users[i].Id)){
                                buttonFlag = true;
                                //break;
                            }
                            else{
                                buttonFlag = false;
                                break;
                            }
                        }
                    }
                    
                setTimeout(() => {
                    this.setDisable(buttonFlag);
                }, 0)
                //console.log('dfgg',this.disabledUserButtons);
                
        this.selection = [...this.selection];
        console.log(this.selection.length);
        
    }

    //Handling activate user permissions
    handleClickActivate() {
        var userIds = [];
        this.selection.forEach(element => {
            userIds.push(element);
        });
        ActivateUsersPermissions({ userIds: userIds })
            .then((result) => {
                console.log(result);
                if(result == 'generic'){        
                    this.fetchUser(this.filterValue, this.searchKey);
                    this.activate=false;
                    this.showToast(result,'Activate');
                }
                else{
                    this.fetchUser(this.filterValue, this.searchKey);
                    this.activate=false;
                    this.showToast(result,'Activate');                 
                }
                

            })
            .catch((error) => {
                console.log('Activate Permission error', error);
            })
            
    }
    //Handling deactivate users permissions
    handleClickDeactivate() {
        var userIds = [];
        this.selection.forEach(element => {
            userIds.push(element);
        });
        DeactivateUsersPermissions({ userIds: userIds })
            .then((result) => {
                this.fetchUser(this.filterValue, this.searchKey);
                this.deactivate=false;
                this.showToast(result,'Deactivate');
            })
            .catch((error) => {
                console.log('Deactivate Permission error', error);
            })
           
    }
    activateVariable() {
        
        if(this.selection.length){
            this.activate = true;
        }else{          
            this.activate = false;
        }
    }
    deactivateVariable() {
        if(this.selection.length){
            this.deactivate = true;
        }else{          
            this.deactivate = false;
        }
    }
    cancel() {
        this.activate = false; 
        this.deactivate = false;
    }
    /*showErrorToast() {
        var msg = "Can't assign permission set to user because some user don't have any profile Please select user which has profile.";
        const event = new ShowToastEvent({
            title: 'Warning !',
            message: msg,   
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.selection = [];
    }*/
    showToast(result,method) {
        this.fetchUser(this.filterValue, this.searchKey);
        if (result == 'Successfull') {
            if(method == 'Activate'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'User Activated Sucessfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            else{
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'User Deactivated Sucessfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            
        } else if (result == 'generic') {
            if(method == 'Activate'){
                const evt = new ShowToastEvent({
                    title: 'Warning !',
                    message: this.ErrorMessageActivate,
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            else{
                const evt = new ShowToastEvent({
                    title: 'Warning !',
                    message: this.ErrorMessageDeactivate,
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }

        }else{
            const evt = new ShowToastEvent({
                title: 'Warning !',
                message: result,
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        this.count = 1;
        this.selection = [];
    }
    handleNumberOfRows(event) {
        this.count = 1;
        if (event.target.value == 'All') {
            this.norowsinpage = event.target.value;
            this.AllUsers = true;
            this.rowsinpage = this.wholeList.length;
            this.setUserOnNumberOfRowsInTableClick();
        } else {
            this.norowsinpage = event.target.value;
            this.rowsinpage = parseInt(event.target.value);
            this.AllUsers = false;
            this.setUserOnNumberOfRowsInTableClick();
        }
        
    }
    setUserOnNumberOfRowsInTableClick() {
        this.to = 0;
        this.from = 0;
        this.Users = [];
        this.UserSize = [];
        var length = Math.ceil(this.wholeList.length / this.rowsinpage);
        if(!this.AllUsers){
            this.to = (this.count) * this.rowsinpage;
            this.from = this.to - this.rowsinpage;
            if (this.to > this.wholeList.length) {
                this.Users = this.wholeList.slice(this.from, this.wholeList.length);
            } else {
                this.Users = this.wholeList.slice(this.from, this.to);
            }
        }else{
            this.Users = this.wholeList;
        }


        if (length < 7) {
            for (let i = 1; i <= length; i++) {
                let x = { Count: i };
                this.UserSize.push(x);
            }
        }
        else {
            if (this.count < 5) {
                for (let i = 2; i <= 6; i++) {
                    let x = { Count: i };
                    this.UserSize.push(x);
                }
            } else {
                if (this.count > length - 5) {
                    for (let i = length - 5; i < length; i++) {
                        let x = { Count: i };
                        this.UserSize.push(x);
                    }
                }
                else {
                    for (let i = this.count - 2; i <= this.count + 2; i++) {
                        let x = { Count: i };
                        this.UserSize.push(x);
                    }
                }
            }
        }

        this.data = this.Users;
        this.selection = [...this.selection];
        var buttonFlag = false;
                if(this.Users.length == 0){
                        buttonFlag = true;
                    }else{
                        for(let i = 0 ; i<this.Users.length;i++){
                            if(!this.selection.includes(this.Users[i].Id)){
                                buttonFlag = true;
                                //break;
                            }
                            else{
                                buttonFlag = false;
                                break;
                            }
                        }
                    }
                    
                setTimeout(() => {
                    this.setDisable(buttonFlag);
                }, 0)
    }
    
}