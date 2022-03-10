const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const cds = require('@sap/cds');
const twilioClient = require("twilio")(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);
const { Accounts, Transactions, Customers } = cds.entities;

const _commitTransaction = async (req) => {
    const { Id, amount, type, description } = req.data, tx = cds.transaction(req);

    if (req.data.hasOwnProperty("type")) {
        const { messageActive } = await tx.run(SELECT.from(Customers, ['messageActive']).where({
            'custID': req.user.attr.ID || "202" // "202" - only for testing 
        }));
        if (type == 'withdraw') {
            const { accountBalance } = await tx.run(SELECT.one.from(Accounts, ['balance']).where('accountid =', Id));
            if (accountBalance < amount) {
                if (messageActive) await twilioClientMessage(`Your last transansction is Failed`);
                req.reject(409, `Transaction Failed. Insufficient balance in the Account #${id}`)
            }
        }
        const commitresults = type == 'deposit' ? await tx.run(UPDATE(Accounts).set('balance +=', amount).where('accountid =', Id)) :
            await tx.run(UPDATE(Accounts).set('balance -=', amount).where('accountid =', Id).and(
                'balance >=', amount
            ));
        if (commitresults == 0) {
            if (messageActive) await twilioClientMessage(`Your last transansction is failed`);
            req.reject(409, `Transansction Failed`);
        } else {
            await tx.run(INSERT({
                accounts_accountid: Id,
                type,
                description,
                amount,
                date: new Date()
            }).into(Transactions));
            const { balance } = await tx.run(SELECT.one.from(Accounts, ['balance']).where('accountid =', Id));
            const traMethod = type == "withdraw" ? "debited by" : "credit with";
            if (messageActive) {
                const message = await twilioClientMessage(`Your account #${Id} has ${traMethod} ${amount}Rs. and your current available balance is ${balance}Rs.`);
                message ? console.log(`Message ${message.sid} has been delivered.`) : console.error(message);
            }
        }
        req._.req.res.send("Transaction Completed Successfully");
    } else {
        req.reject(409, `Please specify the trasaction type`);
    }
};

const twilioClientMessage = async (bodyMsg) => {
    await twilioClient.messages
        .create({
            body: bodyMsg,
            from: process.env.TWILIO_SENDER,
            to: process.env.TWILIO_RECEIVER,
        })
}

const fetchTransactionDetails = async (req) => {
    const tx = cds.transaction(req);
    const { accountid } = await tx.run(SELECT.one.from(Accounts, ['accountid']).where({
        'customers_custID': req.user.attr.ID || "202" // setting the default user id as "202" for testing
    }));

    const trasactionData = await tx.run(SELECT.from(Transactions).where({
        'accounts_accountid': accountid || "1000000000000002"   // setting the default account Id as "1000000000000002" for testing
    }));

    return (trasactionData);
};

const setMessageDetails = async (req) => {
    const { confirmation, ID } = req.data;
    const affecteRows = await cds.transaction(req).run(UPDATE(Customers).set({ messageActive: confirmation }).where({ custID: ID }))
    const sResMessage = affecteRows ? "Message Details updated Successfully" : "Could not update the message details";
    await twilioClientMessage(sResMessage);
    req._.req.res.send(sResMessage);
}

module.exports = {
    _commitTransaction,
    fetchTransactionDetails,
    setMessageDetails
};