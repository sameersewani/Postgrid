@isTest public class UserManagementControllerTest {
    @TestSetup static void TestSetupMethod(){
        PostGrid_AV__Address_Strictness_Settings__c setting = new PostGrid_AV__Address_Strictness_Settings__c();
        setting.Name = 'StrictnessValues';
        setting.PostGrid_AV__End_Date__c = system.today();
        setting.PostGrid_AV__Start_Date__c  = system.today();
        setting.PostGrid_AV__Strictness_Value__c = 'Verified';
        insert setting;
        
        User u = new User(
            ProfileId = [Select Id,Name from Profile where Name = 'Chatter Free User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
    }
    @isTest static void TestfetchUsers(){
        UserManagementController.fetchUsers(null,null);
        UserManagementController.fetchUsers('All',null);
        UserManagementController.fetchUsers('Active',null);
        UserManagementController.fetchUsers('Inactive',null);
        
        UserManagementController.fetchUsers(null,'User');
        UserManagementController.fetchUsers('All','User');
        UserManagementController.fetchUsers('Active','User');
        UserManagementController.fetchUsers('Inactive','User');
        
    }
    
    @isTest static void TestActivateUsersPermissions(){
        
        List<User> u = [Select Id from User where Name = 'last' limit 1];
        list<Id> userList = new list<Id>();
        userList.add(u[0].Id);
        
        
        UserManagementController.ActivateUsersPermissions(userList);
        UserManagementController.ActivateUsersPermissions(userList);
        UserManagementController.DeactivateUsersPermissions(userList);
        
    }
    @isTest static void TestOtherMethods(){
        UsermanagementController.ErrorMessages();
    }
}