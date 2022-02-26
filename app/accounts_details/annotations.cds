using ExecutiveService as service from '../../srv/manager-service';

annotate service.Accounts with @(
    Capabilities : {
        InsertRestrictions     : {Insertable : true},
        DeleteRestrictions     : {Deletable : true},
        UpdateRestrictions     : {
            $Type              : 'Capabilities.UpdateRestrictionsType',
            RequiredProperties : [
                account_status,
                accountid,
                account_type,
                custID,
                city_ID,
                state_ID,
                firstname,
                lastname
            ]
        },
        InsertRestrictions     : { // providing the mandatory fields while creating an item
            $Type              : 'Capabilities.InsertRestrictionsType',
            RequiredProperties : [
                account_status,
                accountid,
                account_type,
                custID,
                city_ID,
                state_ID,
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
                FilterRestrictions : {Filterable : false}
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
            },
            TypeImageUrl : 'https://media.wired.com/photos/5b899992404e112d2df1e94e/master/pass/trash2-01.jpg',
            Description : {
                $Type : 'UI.DataField',
                Value : firstname,
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
        FieldGroup #MultiEdit                           : { // the grop to update in the list report applicatio. Have to enbale the same in settings
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
        DataPoint #FilterLink                           : {Value : phone, },
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
                Value             : 'https://media.wired.com/photos/5b899992404e112d2df1e94e/master/pass/trash2-01.jpg',
                ![@UI.Importance] : #High
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
                Criticality       : balance,
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
                $Type              : 'UI.DataFieldForAction', // will appear at the top table header
                Label              : '{i18n>TriggerAction}',
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

annotate service.Customers with @(
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

annotate service.Transactions with @(

    Capabilities : {
        DeleteRestrictions : {Deletable : false},
        InsertRestrictions : { // providing the mandatory fields while creating an item
            $Type              : 'Capabilities.InsertRestrictionsType',
            RequiredProperties : [
                account_status,
                accountid,
                account_type,
                custID,
                city_ID,
                state_ID,
                firstname,
                lastname
            ]
        },
    },
    UI           : {

        HeaderInfo                           : {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : '{i18n>emp.accountDetail}',
            TypeNamePlural : '{i18n>emp.accountDetail}',
            ImageUrl       : 'https://media.wired.com/photos/5b899992404e112d2df1e94e/master/pass/trash2-01.jpg',
            Title          : {
                $Type : 'UI.DataField',
                Value : accountid
            },
            Description    : {
                $Type : 'UI.DataField',
                Value : firstname
            }
        },
        FieldGroup #AccountDetail            : {
            Data  : [
                {
                    $Type : 'UI.DataField',
                    Value : account_type,
                    Label : '{i18n>emp.AccountType}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : account_status,
                    Label : '{i18n>emp.AccountStatus}'
                }
            ],
            Label : '{@i18n>emp.accountDetailheader}'
        },
        FieldGroup #Balance                  : {
            Data  : [{
                $Type : 'UI.DataField',
                Value : balance,
                Label : '{i18n>emp.Balance}'
            }],
            Label : '{@i18n>emp.Balance}'
        },
        FieldGroup #CustomerDetail           : {
            Data  : [
                {
                    $Type : 'UI.DataField',
                    Value : firstname,
                    Label : '{i18n>emp.firstName}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : lastname,
                    Label : '{i18n>emp.LastName}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : custID,
                    Label : '{i18n>emp.Customerid}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : phone,
                    Label : '{i18n>emp.ContactInfo}'
                },
            ],
            Label : '{@i18n>emp.Customer Details}'
        },
        FieldGroup #BankDetail               : {
            Data  : [
                {
                    $Type : 'UI.DataField',
                    Value : bankID,
                    Label : '{i18n>emp.BankID}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : bankname,
                    Label : '{i18n>emp.BankName}'
                },
                {
                    $Type : 'UI.DataField',
                    Value : status,
                    Label : '{i18n>emp.BankStatus}'
                }
            ],
            Label : '{@i18n>emp.BankDetails}'
        },
        DataPoint #Aggregated                : {
            Title         : '{@i18n>@accountActivity}',
            Value         : activity,
            TargetValue   : 4,
            Visualization : #Rating
        },
        Chart #SpecificationWidthColumnChart : {
            $Type             : 'UI.ChartDefinitionType',
            Title             : 'Product Width Specification Column Chart',
            Description       : 'Describe Column Chart',
            ChartType         : #Column,
            Measures          : [balance],
            Dimensions        : [date],
            MeasureAttributes : [{
                $Type     : 'UI.ChartMeasureAttributeType',
                Measure   : balance,
                Role      : #Axis1,
                DataPoint : '@UI.DataPoint#balance',
            }]
        },
        DataPoint #balance                   : {
            Value         : balance,
            Title         : 'Balance Chart',
            Description   : 'Column Micro Chart',
            TargetValue   : balance,
            ForecastValue : balance
        },
        Identification #Edit                 : [{
            $Type             : 'UI.DataFieldForAction',
            Label             : 'Edit',
            Action            : 'ExecutiveService.EntityContainer/triggerAction',
            ![@UI.Importance] : #High
        }],
        Identification #Copy                 : [{
            $Type             : 'UI.DataFieldForAction',
            Label             : 'Copy',
            Action            : 'ExecutiveService.EntityContainer/triggerAction',
            ![@UI.Importance] : #High,
            Criticality       : #Positive
        }],
        HeaderFacets                         : [
            {
                $Type  : 'UI.ReferenceFacet',
                Target : '@UI.FieldGroup#AccountDetail',
                Label  : '{i18n>emp.HeaderFacetAccount}'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Target : '@UI.FieldGroup#Balance',
                Label  : '{i18n>emp.AccountBalance}'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Target : '@UI.FieldGroup#CustomerDetail',
                Label  : '{i18n>emp.HeaderFacetCustomer}'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Target : '@UI.FieldGroup#BankDetail',
                Label  : '{i18n>emp.HeaderFacetBank}'
            }
        ],
        Facets                               : [
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'Customer information',
                Target : '@UI.FieldGroup#CustomerInfo'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'Bank Information',
                Target : '@UI.FieldGroup#CustomerInfo'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'Transaction Information',
                Target : '@UI.LineItem#transation'
            },
        ],
        FieldGroup #CustomerInfo             : {
            $Type : 'UI.FieldGroupType',
            Label : 'Customer Information',
            Data  : [
                {
                    $Type : 'UI.DataField',
                    Value : firstname,
                    Label : 'First Name: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : lastname,
                    Label : 'Last Name: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : age,
                    Label : 'Age: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : dateOfBirth,
                    Label : 'DOB: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : address,
                    Label : 'Address: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : state.name,
                    Label : 'State: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : city.name,
                    Label : 'City: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : phone,
                    Label : 'Phone No.: '
                }
            ]
        },
        FieldGroup #BankInfo                 : {
            $Type : 'UI.FieldGroupType',
            Label : 'Bank Information',
            Data  : [
                {
                    $Type : 'UI.DataField',
                    Value : bankID,
                    Label : 'Bank ID: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : bankname,
                    Label : 'Bank Name: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : city.name,
                    Label : 'City: '
                },
                {
                    $Type : 'UI.DataField',
                    Value : state.name,
                    Label : 'State: '
                }
            ]
        },
        Identification                       : [
            {
                $Type              : 'UI.DataFieldForAction',
                Label              : 'CWP',
                Action             : 'ExecutiveService.EntityContainer/triggerAction',
                InvocationGrouping : #Isolated,
                ![@UI.Importance]  : #High
            },
            {
                $Type              : 'UI.DataFieldForAction',
                Label              : 'Copy',
                Action             : 'ExecutiveService.EntityContainer/triggerAction',
                Determining        : true,
                InvocationGrouping : #Isolated,
                ![@UI.Importance]  : #High
            }
        ],

        LineItem #transation                 : [ // Table
            {
                $Type             : 'UI.DataField',
                Value             : accountid,
                ![@UI.Importance] : #High,
                Label             : '{i18n>acc.AccountID}'
            },
            {
                $Type             : 'UI.DataField',
                Value             : date,
                ![@UI.Importance] : #High,
                Label             : '{i18n>acc.Date}'
            },
            {
                $Type             : 'UI.DataField',
                Value             : amount,
                ![@UI.Importance] : #High,
                Label             : '{i18n>acc.amount}'
            },
            {
                $Type             : 'UI.DataField',
                Value             : type,
                ![@UI.Importance] : #High,
                Label             : '{i18n>acc.method}'
            }
        ],

        SelectionVariant #SimpleFilter       : {
            Text          : 'Net Transaction less than 10000',
            SelectOptions : [{
                $Type        : 'UI.SelectOptionType',
                PropertyName : amount,
                Ranges       : [{
                    $Type  : 'UI.SelectionRangeType',
                    Sign   : #I,
                    Option : #LT,
                    Low    : '10000'
                }]
            }]
        },
        SelectionVariant #ComplexFilter      : {
            Text          : 'Net Transaction Between 10000 to 200000 and EQ to deposit',
            SelectOptions : [
                {
                    $Type        : 'UI.SelectOptionType',
                    PropertyName : amount,
                    Ranges       : [{
                        Sign   : #I,
                        Option : #BT,
                        Low    : '10000',
                        High   : '200000'
                    }]
                },
                {
                    $Type        : 'UI.SelectOptionType',
                    PropertyName : type,
                    Ranges       : [{
                        $Type  : 'UI.SelectionRangeType',
                        Sign   : #I,
                        Option : #EQ,
                        Low    : 'deposit',
                    }, ],
                }
            ]
        }

    }
);
annotate service.Accounts with {
    createdAt @Common.Label : '{i18n>CreatedAt}'
};
