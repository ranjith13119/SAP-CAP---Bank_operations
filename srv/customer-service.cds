using { sap.capire.bank_details as my } from '../db/schema';

// service Customer @(requires: ['authenticated-user']) {
service Customer {
    entity Customers @(restrict: [ { grant: ['READ', 'UPDATE'], to: 'customer', where: 'custID = $user' }]) 
    as projection on my.Customers  {
        @readonly key custID,
        firstname,
        lastname,
        dateOfBirth,
        @readonly accounts.accountid as AccountId,
        @readonly accounts.balance as Balance,
        @readonly accounts.account_type as AccountType,
        @readonly accounts.account_status as AccountStatus,
        @readonly bank.bankID as BankId,
        @readonly bank.bankname as BankName,
        @readonly status as ProfileStatus,
        address,    
        city.name as CityName,
        state.name as StateName,
        accounts,
        state,
        status,
        message,
        city,
        bank,
        phone,
        messageActive
    } ;
    
    entity Accounts @(restrict: [ { grant: ['READ', 'UPDATE'], to: 'customer', where: 'custID = $user'}])
    as projection on my.Accounts{
        @readonly key accountid,
        account_type,
        account_status,
        balance,
        customers.custID,
        customers.firstname ,
        customers.lastname ,
        customers.address,
        customers.city,
        customers.state,
        customers.phone,
        @readonly customers.bank.bankID,
        @readonly customers.bank.bankname,
        message,
        createdAt,
        transactions,
        customers
    };

    entity Transactions @(restrict: [ { grant: ['READ', 'CREATE'], to: 'customer'}]) 
    as projection on my.Transactions { * , ID as transactionsId};
    action cancelMessage(ID : String, confirmation : Boolean);
    action accountTransaction(Id : Integer64, type : String, amount : Double, description: String)
}

annotate Customer.Accounts with @(
    UI : {
        HeaderInfo : {
           TypeName :  '{i18n>emp.TypeName}',
           TypeNamePlural : '{i18n>emp.TypeNamePlural}',
           Title : { $Type: 'UI.DataField', Value: customers.firstname }
        },
        Identification: [{ Value:customers.firstname }],
        SelectionFields: [ accountid , account_type , account_status, createdAt],
        LineItem: [
        {$Type: 'UI.DataField', Value: accountid },
        {$Type: 'UI.DataField', Value: account_type },
        {$Type: 'UI.DataField', Value: account_status },
        {$Type: 'UI.DataField', Value: balance },
        {$Type: 'UI.DataField', Value: customers.bank.bankID, Label:'{i18n>emp.BankID}' },
        {$Type: 'UI.DataField', Value: customers.bank.bankname , Label:'{i18n>emp.BankName}'},
      ],
        HeaderFacets: [       
            {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#AccountDetail', Label:'{i18n>emp.HeaderFacetAccount}' },
            {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#CustomerDetail', Label:'{i18n>emp.HeaderFacetCustomer}' },
            {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#BankDetail', Label:'{i18n>emp.HeaderFacetBank}' },
            {$Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#Balance', Label:'{i18n>emp.AccountBalance}'}
        ],
        Facets: [
            {
                $Type: 'UI.CollectionFacet',
                Label: '{i18n>emp.AccountTransectionInformation}',
                Facets: [
                    {$Type: 'UI.ReferenceFacet', Target: 'transactions/@UI.LineItem'}
                ]
            },
            {
                $Type: 'UI.CollectionFacet',
                Label: '{i18n>emp.AccountInformation}',
                Facets: [
                    {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#AccountFacet'},
                ]
            },
            {
                $Type: 'UI.CollectionFacet',
                Label: '{i18n>emp.AccountCustomerInformation}',
                Facets: [
                    {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#CustomerFacet'},
                ]
            },
            {
                $Type: 'UI.CollectionFacet',
                Label: '{i18n>emp.AccountBankInformation}',
                Facets: [
                    {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#BankFacet'}
                ]
            }
        ],
        DataPoint#Balance: { Value: balance },
        FieldGroup#AccountFacet: { 
            Data:[
                {$Type: 'UI.DataField', Value: accountid },
                {$Type: 'UI.DataField', Value: account_type },
                {$Type: 'UI.DataField', Value: account_status},
                {$Type: 'UI.DataField', Value: balance },
                {$Type: 'UI.DataField', Value: message },
                {$Type: 'UI.DataField', Value: createdAt }
                
            ]
        },     
        FieldGroup#CustomerFacet: {
            Data:[
                {$Type: 'UI.DataField', Value: customers.custID },
                {$Type: 'UI.DataField', Value: customers.firstname },
                {$Type: 'UI.DataField', Value: customers.lastname },
                {$Type: 'UI.DataField', Value: customers.dateOfBirth },
                {$Type: 'UI.DataField', Value: customers.status },
                {$Type: 'UI.DataField', Value: customers.message }
            ]
        },     
        FieldGroup#BankFacet: {
            Data:[
                {$Type: 'UI.DataField', Value: customers.bank.bankID },
                {$Type: 'UI.DataField', Value: customers.bank.bankname },
                {$Type: 'UI.DataField', Value: customers.bank.status }
            ]
        },   
        FieldGroup#AccountDetail: {
            Data:[
                {$Type: 'UI.DataField', Value: accountid },
                {$Type: 'UI.DataField', Value: account_type },
                {$Type: 'UI.DataField', Value: account_status }
            ]
        },
        FieldGroup#CustomerDetail: {
            Data:[
                {$Type: 'UI.DataField', Value: customers.custID },
                {$Type: 'UI.DataField', Value: customers.firstname },
                {$Type: 'UI.DataField', Value: customers.lastname },
                {$Type: 'UI.DataField', Value: customers.status }
            ]
        },
        FieldGroup#BankDetail: {
            Data:[
            {$Type: 'UI.DataField', Value: customers.bank.bankID, Label: '{i18n>emp.BankID}' },
            {$Type: 'UI.DataField', Value: customers.bank.bankname, Label: '{i18n>emp.BankName}' },
            {$Type: 'UI.DataField', Value: customers.bank.status, Label: '{i18n>emp.BankStatus}' }
            ]
        }
    }
);

annotate Customer.Transactions with @ (
    UI : {
         HeaderInfo : {
           TypeName :  '{i18n>emp.TransectionTypeName}',
           TypeNamePlural : '{i18n>emp.TransectionTypeNamePlural}',
           Title : { $Type: 'UI.DataField', Value: accounts.accountid }
        },
        LineItem: [
            {$Type: 'UI.DataField', Value: type, Label: '{i18n>emp.Transectiontype}'  },        
            {$Type: 'UI.DataField', Value: amount, Label: '{i18n>emp.TransectionAmount}'  },
            {$Type: 'UI.DataField', Value: description, Label: '{i18n>emp.TransectionDescription}'  },
            {$Type: 'UI.DataField', Value: date, Label: '{i18n>emp.TransectionDate}'  }
       ]
    }
);

annotate Customer.Accounts with {
  accountid @( Common: { Label: '{i18n>emp.AccountID}'} );
  account_type @( Common.Label: '{i18n>emp.AccountType}' );
  account_status @( Common.Label: '{i18n>emp.AccountStatus}');
  createdAt @( Common.Label: '{i18n>emp.AccountCreatedAt}' );
  message @( Common.Label: '{i18n>emp.AccountMessage}');
  balance @( Common.Label: '{i18n>emp.AccountBalance}');
}

annotate Customer.Customers with {
  custID @( Common : { Label: '{i18n>emp.CustomerID}' });
  firstname @( Common : { Label: '{i18n>emp.FirstName}'} );
  lastname @( Common : { Label: '{i18n>emp.LastName}'} );
  dateOfBirth @( Common : { Label: '{i18n>emp.DOB}'} );
  address @( Common : { Label: '{i18n>emp.Address}' } );
  status @( Common : { Label: '{i18n>emp.CustomerStatus}'});
  message @( Common : { Label: '{i18n>emp.CustomerMessage}'});
}