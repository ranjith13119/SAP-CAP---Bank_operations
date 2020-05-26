using { sap.capire.bank_details as my } from '../db/schema';

service ExecutiveService {//@(requires: 'authenticated-user' ){

   
    entity Accounts //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Accounts {
        key accountid,
        account_type,
        account_status,
        balance,    
        customers.custID,
        customers.firstname ,
        customers.lastname,
        customers.bank.bankID,
        customers.bank.bankname,
        message,
        createdAt,
        transections,
        customers
    } ;

    entity Transections //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Transections;

    entity State //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.State {
        key ID,
        name
    };
    
   
    entity Banks //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Banks {
        key bankID,
        bankname,
        //customers.cust_ID as CustomerID,
        //customers.accounts.account_id as AccountID,
        state.name as StateName,
        city.name as CityName,
        state,
        city,
        customers,
        status
    };

    entity Customers //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Customers  {
        key custID,
        firstname,
        lastname,
        bank.bankID as BankId,
        bank.bankname as BankName,
    //    accounts.accountid,
    //    accounts.account_type,
    //    accounts.Balance,
    //    accounts.createdAt as Date,
        status as Accountstatus,
        address,    
        city.name as CityName,
        state.name as StateName,
        accounts,
        state,
        city,
        bank
    };

}
