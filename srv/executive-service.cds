using { sap.capire.bank_details as my } from '../db/schema';


service EmployeeService @(requires: 'authenticated-user' ) {
        
    entity Banks @(restrict: [ { grant: ['READ'], to: 'employee', where: 'bankID = $user.bankID' }]) 
    as projection on my.Banks {
        key bankID,
        bankname,
        state.name as StateName,
        city.name as CityName,
        state,
        city,
        customers
    };

    entity Customers @(restrict: [ { grant: '*', to: 'employee', where: 'bankID = $user.bankID' }])
    as projection on my.Customers  {
        @readonly key custID,
        firstname,
        lastname,
        bank.bankID as BankId,
        bank.bankname as BankName,
        status as Accountstatus,
        address,    
        city.name as CityName,
        state.name as StateName,
        accounts,
        state,
        city,
        bank
    };

    entity Accounts @(restrict: [ { grant: '*', to: 'employee', where: 'bankID = $user.bankID' }])
    as projection on my.Accounts {
        @readonly key accountid,
        account_type,
        account_status,
        balance,
        customers.custID,
        customers.firstname ,
        customers.lastname ,
        customers.bank.bankID,
        customers.bank.bankname,
        customers.phone,
        message,
        createdAt,
        transactions,
        customers
    } ;

    @readonly entity Transactions @(restrict: [ { grant: 'READ', to: 'employee', where: 'bankID = $user.bankID' }])
    as projection on my.Transactions;
}
