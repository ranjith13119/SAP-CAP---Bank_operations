namespace sap.capire.bank_details;

using {
    Currency,
    managed,
    cuid,
    temporal
} from '@sap/cds/common';

type Acc_type : String enum {
    Savings;
    Current;
}

type Status : String enum {
    Active;
    Processing;
    DeActivated;
}

type Transaction_type : String enum {
    deposit;
    withdraw;
}

entity State {
    key ID        : Integer;
        name      : localized String(100) not null @assert.unique;
        customers : Composition of many Customers
                        on customers.state = $self;
        banks     : Composition of many Banks
                        on banks.state = $self;
}

entity City {
    key ID        : Integer;
        name      : localized String(100) not null @assert.unique;
        customers : Composition of many Customers
                        on customers.city = $self;
        banks     : Composition of many Banks
                        on banks.city = $self;
}

entity Banks : managed {
    key bankID    : Integer    @assert.unique;
        bankname  : String(100)@assert.unique;
        state     : Composition of State;
        city      : Composition of City;
        status    : Status default 'Processing';
        customers : Composition of many Customers
                        on customers.bank = $self;
}

entity Customers : managed {
    key custID      : Integer                           @assert.unique;
        firstname   : localized String(50);
        lastname    : localized String(50);
        age         : Integer;
        dateOfBirth : Date;
        bank        : Composition of Banks;
        address     : localized String(500);
        state       : Composition of State;
        city        : Composition of City;
        phone       : Integer;
        status      : Status default 'Processing';
        message     : String(50) default 'Customer Created Successfully';
        accounts    : Composition of many Accounts
                          on accounts.customers = $self @Validation.Maximum : 2  @Validation.Minimum : 1;
}

entity Accounts : managed {
    key accountid            : Integer64 @assert.unique;
        customers            : Association to Customers;
        account_type         : Acc_type default 'Savings';
        balance              : Integer;
        account_status       : Status default 'Processing';
        message              : String(50) default 'Account Created Successfully';
        transactions         : Composition of many Transactions
                                   on transactions.accounts = $self;
        activity             : Integer;
}

entity Transactions : cuid {
    key accounts    : Association to Accounts;
        type        : Transaction_type;
        description : String(100);
        date        : DateTime @cds.on.update : $now;
        amount      : Integer;
}
