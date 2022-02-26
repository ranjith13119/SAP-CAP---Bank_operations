using {sap.capire.bank_details as my} from '../db/schema';

service ExecutiveService { //@(requires: 'authenticated-user' ){


    entity Accounts //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Accounts {
        key accountid, account_type, activity, account_status, balance, customers.custID, customers.phone, customers.firstname, customers.lastname, customers.state, customers.city, customers.bank.bankID, customers.bank.bankname, message, createdAt, transactions, customers
    };

    entity Transections //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Transactions;

    entity State //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.State {
        key ID, name
    };

    action triggerAction();

    entity Banks //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Banks {
        key bankID, bankname, state.name as StateName, city.name as CityName, state, city, customers, status
    };

    entity Customers //@(restrict: [ { grant: '*', to: 'Manager'}])
    as projection on my.Customers {
        * , key custID, firstname, lastname, bank.bankID as BankId, bank.bankname as BankName, phone, status as Accountstatus, address, city.name as CityName, state.name as StateName, accounts, state, city, bank
    };

    annotate ExecutiveService.Accounts with @(
        Capabilities : {
            InsertRestrictions     : {Insertable : true},
            DeleteRestrictions     : {Deletable : true},
            UpdateRestrictions  : {
                $Type : 'Capabilities.UpdateRestrictionsType',
                RequiredProperties : [
                    account_status,
                    accountid, 
                    account_type,
                    custID,
                    city_ID, state_ID,
                    firstname,
                    lastname
                ]
            },
            InsertRestrictions : {                          // providing the mandatory fields while creating an item
                $Type : 'Capabilities.InsertRestrictionsType',
                RequiredProperties : [
                    account_status,
                    accountid, 
                    account_type,
                    custID,
                    city_ID, state_ID,
                    firstname,
                    lastname
                ]
            },
            NavigationRestrictions : {RestrictedProperties : [
                {
                    NavigationProperty : city,
                    SortRestrictions   : {Sortable : false}
                },
                {
                    NavigationProperty : customers.bank,
                    InsertRestrictions : {Insertable : true},
                    DeleteRestrictions : {
                        $Type     : 'Capabilities.DeleteRestrictionsType',
                        Deletable : false,
                    }
                },
                {
                NavigationProperty : customers.bank,
                FilterRestrictions : {
                    Filterable : false
                }
            }
            ]},
            FilterRestrictions     : {FilterExpressionRestrictions : [{
                Property           : createdAt,
                AllowedExpressions : 'SingleRange'
            }]}
        },

        UI           : {
            SelectionFields                                 : [ // Filters
                accountid,
                account_status,
                account_type,
                custID,
                firstname,
                lastname,
                createdAt
            ],
            FieldGroup #BankDetail                          : {Data : [
                {
                    $Type : 'UI.DataField',
                    Value : customers.bank.bankID,
                    Label : '{i18n>emp.BankID}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : customers.bank.bankname,
                    Label : '{i18n>emp.BankName}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : customers.bank.status,
                    Label : '{i18n>emp.BankStatus}'
                }
            ]},
            HeaderInfo                                      : { // Table Header info
                TypeName       : '{i18n>acc.AccountHeader}',
                TypeNamePlural : '{i18n>acc.AccountHeaderPlural}',
                Title          : {
                    $Type : 'UI.DataField',
                    Value : accountid
                }
            },
            SelectionPresentationVariant #DefaultVariant    : {
                Text                : 'Account Analysis',
                SelectionVariant    : ![@UI.SelectionVariant#DefaultSelectionVariant],
                PresentationVariant : ![@UI.PresentationVariant#DefaultPresentationVariant]
            },
            PresentationVariant #DefaultPresentationVariant : {
                Visualizations : ['@UI.LineItem'],
                RequestAtLeast : [
                    accountid,
                    firstname
                ],
                SortOrder      : [
                    {
                        Property   : firstname,
                        Descending : false
                    },
                    {Property : balance}
                ]
            },
            SelectionVariant #DefaultSelectionVariant       : {
                Text          : 'Open',
                SelectOptions : [{
                    $Type        : 'UI.SelectOptionType',
                    PropertyName : balance,
                    Ranges       : [{
                        $Type  : 'UI.SelectionRangeType',
                        Sign   : #I,
                        Option : #GE,
                        Low    : '20000'
                    }]
                }]
            },
            FieldGroup #AccountFltr                         : { // Filter Group in Filter dialog
                Data  : [
                    {
                        $Type : 'UI.DataField',
                        Value : accountid
                    },
                    {
                        $Type : 'UI.DataField',
                        Value : account_type
                    },
                    {
                        $Type : 'UI.DataField',
                        Value : account_status
                    }
                ],
                Label : 'Account Details'
            },
            FieldGroup #CityFilter                          : { // Filter Group in Filter dialog
                Data  : [
                    {
                        $Type : 'UI.DataField',
                        Value : city_ID
                    },
                    {
                        $Type : 'UI.DataField',
                        Value : state_ID
                    },
                ],
                Label : 'City Details'
            },
            FieldGroup #MultiEdit                          : { // the grop to update in the list report applicatio. Have to enbale the same in settings
                Data  : [
                    {
                        $Type : 'UI.DataField',
                        Value : city_ID
                    },
                    {
                        $Type : 'UI.DataField',
                        Value : state_ID
                    },
                ],
                Label : 'City Details'
            },
            FilterFacets                                    : [{
                $Type  : 'UI.ReferenceFacet',
                Target : '@UI.FieldGroup#AccountFltr'
            }],
            QuickViewFacets                                 : [ // showing records as grouped in dialog
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Main Contact Person',
                    Target : 'customers/@Communication.Contact'
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Phone',
                    Target : '@UI.DataPoint#FilterLink     '
                }
            ],
            DataPoint #FilterLink                                   : {Value : phone, },
            DataPoint #Activity                             : {
                Value         : 'activity',
                TargetValue   : 5,
                Visualization : #Rating
            },
            LineItem                                        : [ // Table
                {
                    $Type             : 'UI.DataField',
                    Value             : accountid,
                    ![@UI.Importance] : #High,
                    Label             : '{i18n>acc.AccountID}'
                },
                {
                    $Type             : 'UI.DataField',
                    Value             : account_type,
                    ![@UI.Importance] : #High,
                    Label             : '{i18n>acc.AccountType}'
                },
                {
                    $Type             : 'UI.DataFieldForAnnotation',
                    Target            : 'customers/@Communication.Contact',
                    ![@UI.Importance] : #High,
                    Label             : '{i18n>acc.CustomerID}'
                },
                {
                    $Type             : 'UI.DataField',
                    Value             : firstname,
                    ![@UI.Importance] : #High,
                    Label             : '{i18n>acc.FirstName}'
                },
                {
                    $Type             : 'UI.DataField',
                    Value             : lastname,
                    ![@UI.Importance] : #High,
                    Label             : '{i18n>acc.LastName}'
                },
                {
                    $Type             : 'UI.DataField',
                    Value             : balance,
                    ![@UI.Importance] : #High,
                    Criticality :   balance,
                    Label             : '{i18n>acc.Balance}'
                },
                {
                    $Type  : 'UI.DataFieldForAnnotation',
                    Label  : 'Recent Avtivity',
                    Target : '@UI.DataPoint#Activity'
                },
                {
                    $Type  : 'UI.DataFieldForAnnotation',
                    Target : '@UI.FieldGroup#BankDetail',
                    Label  : 'Bank information'
                },
                {
                    $Type : 'UI.DataFieldWithUrl',
                    Url   : 'https://github.com/ranjith13119/SAP-CAP---Bank_operations.git',
                    Value : 'Bank-Git Repo',
                    Label : 'Repository'
                },
                {
                    $Type              : 'UI.DataFieldForAction',   // will appear at the top table header
                    Label              : 'Trigger Action',
                    Action             : 'ExecutiveService.EntityContainer/triggerAction',
                    InvocationGrouping : #Isolated
                },
                {
                    $Type          : 'UI.DataFieldForIntentBasedNavigation',
                    Label          : 'Intenet Based Navigation',
                    SemanticObject : 'Customer',
                    Action         : 'Detail',
                    Inline         : false
                },
            ]
        }
    );

    annotate ExecutiveService.Customers with @(
        FieldGroup #FilterGrp : {
            Data  : [{
                $Type : 'UI.DataField',
                Value : CityName
            }],
            Label : 'City Using Field Group'
        },
        Communication.Contact : {
            fn    : {$edmJson : {
                $Apply    : [
                    'firstname',
                    'lastname'
                ],
                $Function : 'odata.concat',
            }, },
            tel   : [
                {
                    type : #fax,
                    uri  : '+91-8072707817'
                },
                {
                    type : [
                        #preferred,
                        #work
                    ],
                    uri  : '+91-8072707817'
                },
            ],
            email : [{
                type    : [ #work],
                address : 'ranjith13119@gmail.com'
            }]
        }
    );

};
