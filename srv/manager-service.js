const cds = require('@sap/cds')
const { Banks, Customers, Accounts } = cds.entities

module.exports = cds.service.impl((srv)=> {

    srv.before('CREATE', 'Transections', _beforeTransection)  // function to check whether the account have the enough balance
    srv.after('CREATE',  'Banks', _afterCreationBank) // Just to print the created BankId 

    //Create a Event to update the Status to "Active"
    srv.on(['CREATE'], ['Banks', 'Accounts', 'Customers' ], req => {
        var  KEY = ''
        const targetname = req.target.name.split(".")[1]
        if(targetname == 'Banks') {
            KEY = [{ ID: req.data.bankID, entity : targetname }]
        } else if( targetname == 'Accounts') {
            KEY = [{ ID: req.data.accountid, entity : targetname }]
        } else {
            KEY = [{ ID: req.data.custID, entity : targetname }]
        }
        const payload = {
            KEY : KEY
        }
        srv.emit('Bank/Account/Customer/Created', payload)
        console.log('<< Emitted Bank/Account/Customer/Created', payload)
    })
    
    // Listing the Event and Updating the status
    srv.on('Bank/Account/Customer/Created', async msg  => {
        const tx = cds.tx(msg)
        console.log(msg.data)
        if(msg.data.KEY[0].entity == 'Banks') {
            const affectedrows = await tx.run(UPDATE(Banks).set({status:'Active'}).where('bankID =', msg.data.KEY[0].ID))
            if (affectedrows == 0) { console.log(`Status of Bank ${msg.data.KEY[0].ID} could not be updated`); return }
            let customercount = await(tx.run(SELECT.from(Customers).where('bank_bankID =', msg.data.KEY[0].ID)))
            if(customercount.length > 0) {
                const affectedcustomerrows = await tx.run(UPDATE(Customers).set({status:'Active'}).where('bank_bankID =', msg.data.KEY[0].ID))
                if (affectedcustomerrows == 0) { console.log(`Status of all the customers in Bank ${msg.data.KEY[0].ID} could not be updated`); return }
                console.log(`Status of Bank Id ${msg.data.KEY[0].ID} and its customers are updated successfully`)
            } else {
                console.log(`Status of Bank Id ${msg.data.KEY[0].ID} updated successfully`)
            }
            

        } else if(msg.data.KEY[0].entity == 'Accounts') {
            await tx.run(UPDATE(Accounts).set({account_status : 'Active' }).where('accountid =', msg.data.KEY[0].ID)).then((affectedrows)=>{
                if(affectedrows == 0) {
                    console.log(`Status of Accounts Id ${msg.data.KEY[0].ID} could not be updated`)
                } else {
                    console.log(`Status of Accounts Id ${msg.data.KEY[0].ID} updated successfully`)
                }
            })
        } else {
            
            const affectedcustomerrows = await tx.run(UPDATE(Customers).set({status:'Active'}).where('custID =', msg.data.KEY[0].ID))
            if (affectedcustomerrows == 0) { console.log(`Status of Customer ${msg.data.KEY[0].ID} could not be updated`); return }
            let accountCount = await tx.run(SELECT.from(Accounts).where('customers_custID=', msg.data.KEY[0].ID))
            if(accountCount.lenght > 0) {
                const affectedAccountrows = await tx.run(UPDATE(Accounts).set({account_status : 'Active' }).where('customers_custID=', msg.data.KEY[0].ID))
                if (affectedAccountrows == 0) { console.log(`Status of customer's accounts ${msg.data.KEY[0].ID} could not be updated`); return }
                console.log(`Status of Customer Id ${msg.data.KEY[0].ID} and his accounts are updated successfully`)
            } else {
                 console.log(`Status of CustomerId ${msg.data.KEY[0].ID} is updated successfully`)
            }
        }
    })

    //srv.on('READ', 'Banks',_onInfoCreation)
})

 async function _beforeTransection(req) {
    const data = req.data
    console.log(req.user)
    return cds.transaction(req).run(()=> { 
        if(data.hasOwnProperty("type")) {
            if(data.type === 'Deposit') {
                UPDATE(Accounts).set('balance +=', data.amount).where('accountid =', data.accounts_accountid)
            } else {
                UPDATE(Accounts).set('balance -=', data.amount).where('accountid =', data.accounts_accountid).and(
                    'balance >=', data.amount
                )
            }
        }
    }).then((affectedrows) => {
        if(affectedrows == 0) {
            req.error(409,`${data.amount} exceeds stock for book #${data.accounts_accountid}`)
        }
    })
}

 async function _afterCreationBank(bankdetails, req) {
    console.log(req.data)
    console.log(`Bank ${bankdetails.bankID} is Created`)
    for(let i in bankdetails.customers) {
        console.log(`Customer ${bankdetails.customers[i].custID} is Created`)
        for(let j in bankdetails.customers[i].accounts) {
            console.log(`Account ${bankdetails.customers[i].accounts[j].accountid} is Created`)
            for(let k in bankdetails.customers[i].accounts[j].transections) {
                console.log(`Transecction ${bankdetails.customers[i].accounts[j].transections[k].ID} is Created`)
            }
        }
    }
}

// async function _onInfoCreation(req) {
//     //await tx.read(Banks).where('ID', 1)
//     //SELECT.from(Authors)
//   return await(cds.transaction(req).run(SELECT.from(Banks)))
// }



    
    //Create a Event to update the Status to "DeActivated"
  /*  srv.before('DELETE', ['Accounts', 'Customers' ], req => {
        console.log(req.data)
        var  KEY = ''
        const targetname = req.target.name.split(".")[1]    
        KEY = targetname == 'Accounts' ?  [{ ID: req.data.accountid, entity : targetname }] : [{ ID: req.data.custID, entity : targetname }]
        const payload = {
            KEY : KEY
        }
        srv.emit('Account/Customer/Deleted', payload)
        console.log('<< Emitted Account/Customer/Created', payload)
    }) */

    // Listing the Event and Updating the status
 /*   srv.on('Account/Customer/Deleted', async msg=>{
        const tx = cds.tx(msg)
        console.log(msg.data)
        if(msg.data.KEY[0].entity == 'Accounts') { 
            let CustomerID = await(tx.run(SELECT.one('customers_custID').from(Accounts).where('accountid =', msg.data.KEY[0].ID)))
            console.log(CustomerID)
            const fetchedAccount = await(tx.run(SELECT.from(Accounts).where('customers_custID =', CustomerID)))
            console.log(fetchedAccount.length)
            if(fetchedAccount.length == 0 ) {
                const affectedrows = await tx.run(UPDATE(Customers).set({status:'DeActivated'}).where('custID =', msg.data.KEY[0].ID))
                affectedrows == 0 ? console.log(`Now the Customer ${msg.data.KEY[0].ID} is DeActivated`) : null
            }
        } else {
            let BankID = await(tx.run(SELECT.from(Customers)))
            console.log(BankID)
            const fetchedCustomers = await(tx.run(SELECT.from(Customers).where('bank_bankID =', BankID)))
            console.log(fetchedCustomers.length)
            if(fetchedCustomers.length == 0 ) {
                const affectedrows = await tx.run(UPDATE(Banks).set({status:'DeActivated'}).where('bankID =', msg.data.KEY[0].ID))
                affectedrows == 0 ? console.log(`Now the Bank ${msg.data.KEY[0].ID} is DeActivated`) : null
            }
        }
    })*/