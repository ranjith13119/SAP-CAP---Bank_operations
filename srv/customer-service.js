const cds = require('@sap/cds')
const { Accounts } = cds.entities

module.exports = cds.service.impl((srv)=> { 
     srv.before('CREATE', 'Transections', _beforeTransection)
})
 async function _beforeTransection(req) {
     
    if(!req.user.is('customer') ) return

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