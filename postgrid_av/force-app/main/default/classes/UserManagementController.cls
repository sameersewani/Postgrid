public with sharing class UserManagementController {
    @AuraEnabled
    //Fetching Users to show in User Table.
    public static List<User> fetchUsers(String filterValue , String searchKey){
        List<User> userList = new List<user>();
        
        
        if(searchKey != null && searchKey != ''){
            searchKey = '%'+searchKey+'%';
            
            if(filterValue == 'All' || filterValue == null || filterValue ==''){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User where Name like :searchKey OR Profile.Name like :searchKey];
            }else if (filterValue == 'Active'){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User where ((Name like :searchKey) OR (Profile.Name like :searchKey)) AND (PostGrid_AV__Permission_Set_Checkbox__c = true)];
            }
            else if(filterValue == 'Inactive'){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User where ((Name like :searchKey) OR (Profile.Name like :searchKey)) AND (PostGrid_AV__Permission_Set_Checkbox__c = false)];
            }           
        }
        else{
            if(filterValue == 'All' || filterValue == null || filterValue ==''){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User];
            }else if (filterValue == 'Active'){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User where PostGrid_AV__Permission_Set_Checkbox__c = true];
            }
            else if(filterValue == 'Inactive'){
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User where PostGrid_AV__Permission_Set_Checkbox__c = false];
            }
            else{
                userList = [Select Name , Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c from User];
            }
        }
        return userList;
    } 
    
    //Assigning Permission Set to User And Updating StartDate and ActiveCheckbox
    @AuraEnabled
    public static String ActivateUsersPermissions(List<Id> userIds){
        try {
            String errorMessageUser;
            String errorMessage;
            Boolean checkActive;
            Date todayDate = Date.today();
            String permissionSetName = label.Print_Mail_Application;
            
            Map<Id,String> assignedUsers = new Map<Id,String>();
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            map<String,String> pSetAssign = new map<String,String>();
            list<User> userList = [SELECT ID,Name,Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c FROM User WHERE Id IN :userIds];
            List<PermissionSet> permissionList = [Select Id ,Name from PermissionSet where Name = :permissionSetName Limit 1];
            
            List<PermissionSetAssignment> permissionSetAssignmentList = [Select Id ,PermissionSetId,AssigneeId from PermissionSetAssignment where PermissionSetId = :permissionList[0].Id];
            
            for(PermissionSetAssignment permissionSet : permissionSetAssignmentList){
                assignedUsers.put(permissionSet.AssigneeId,'');
            }
            System.debug(assignedUsers);
            for (User users : userList)
            {	
                if(!assignedUsers.containsKey(users.Id))
                {
                    if(permissionList.size() != 0){
                        PermissionSetAssignment permissionSet = new PermissionSetAssignment (PermissionSetId = permissionList[0].Id, AssigneeId = users.Id);
                        permissionSetList.add(permissionSet);
                    }
                    checkActive = true;
                }
            }
            for(PermissionSetAssignment p:permissionSetList){
                pSetAssign.put(p.AssigneeId,p.PermissionSetId);
            }
            
            list<String> idList = new list<String>();
            list<String> successUserId = new list<String>();
            Database.SaveResult[] permissionSetResult = Database.insert(permissionSetList,false);
            for(Database.SaveResult result : permissionSetResult){
                if(result.isSuccess()) {
                    idList.add(result.getId());
                }
                else {
                    for(Database.Error error : result.getErrors()){
                        errorMessage = error.getMessage();
                    }
                }
            }
            for(PermissionSetAssignment assignment:[SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE ID IN :idList]){
                successUserId.add(assignment.AssigneeId);
            }
            List<User> finalUsers = new List<User>();
            for(User users:userList){
                if(successUserId.contains(users.Id)){
                    users.PostGrid_AV__Permission_Set_Checkbox__c = true;
                    users.PostGrid_AV__Activation_Date__c = todayDate;
                    finalUsers.add(users);
                }
            }
                Database.SaveResult[] results = Database.update(finalUsers,false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                    }
                    else{
                        for(Database.Error error : result.getErrors()){
                            errorMessageUser = error.getMessage();
                        }
                    }
                }
            if(String.isBlank(errorMessageUser) && String.isBlank(errorMessage) && checkActive == true){
                return 'Successfull';
            }
            else if(!String.isBlank(errorMessage)){
                return errorMessage;
            }
            else if(!String.isBlank(errorMessageUser)){
                return errorMessageUser;
            }
            else {
                return 'generic';
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Removing Permission Set from User And Updating StartDate and ActiveCheckbox
    @AuraEnabled
    public static String DeactivateUsersPermissions(List<Id>userIds){
        try {
            String returnString;
            String errorMessageUser;
            String permissionSetName = label.Print_Mail_Application;
            List<PermissionSet> permissionSetList = [Select Id ,Name from PermissionSet where Name = :permissionSetName Limit 1];
            if(permissionSetList.size()!=0){
                Id permissionSetId = permissionSetList[0].Id;
                List<PermissionSetAssignment> permissionSetAssignmentList = [Select Id from PermissionSetAssignment where PermissionSetId = :permissionSetId And AssigneeId IN:userIds];
                // Deleting permissionSet Assignment record for selected Users
                if(permissionSetAssignmentList != null){
                    delete permissionSetAssignmentList;
                }
                list<User> userList = [SELECT ID,Name,Profile.Name,PostGrid_AV__Permission_Set_Checkbox__c,PostGrid_AV__Activation_Date__c FROM User WHERE Id IN :userIds];
                for(User users : userList){
                    users.PostGrid_AV__Permission_Set_Checkbox__c = false;
                    users.PostGrid_AV__Activation_Date__c = null;
                }
                //Updating Fields on User
                Database.SaveResult[] results =  Database.update(userList,false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                    }
                    else{
                        for(Database.Error error : result.getErrors()){
                            errorMessageUser = error.getMessage();
                        }
                    }
                }    
            }
            if(String.isBlank(errorMessageUser)){
            	return 'Successfull';           
            }else{
                return errorMessageUser;
            }       
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Fetching Common Error Message from Custom Label.
    @AuraEnabled
    public static String ErrorMessages(){
        return label.Cannot_Deactivate_this_User + ','+label.User_is_already_Active;
    }
}