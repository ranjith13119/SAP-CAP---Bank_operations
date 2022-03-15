const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const cds = require("@sap/cds");
const twilioClient = require("twilio")(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);
const { Accounts, Transactions, Customers } = cds.entities;
const debug_customer = require("debug")("srv:customer-service"); // cf set-env bank_tasks-srv DEBUG 'srv:*' ==> to dubug on cf
const log = require("cf-nodejs-logging-support");
log.setLoggingLevel("info");
log.registerCustomFields(["Account", "amount"]);

const _commitTransaction = async (req) => {
  const { Id, amount, type, description } = req.data;

  if (req.data.hasOwnProperty("type")) {
    const { messageActive } = await SELECT.from(Customers, [
      "messageActive",
    ]).where({
      custID: req.user.attr.ID[0] || "202",
    });
    if (type == "withdraw") {
      const { accountBalance } = await SELECT.one
        .from(Accounts, ["balance"])
        .where("accountid =", Id);
      if (accountBalance < amount) {
        if (messageActive)
          await twilioClientMessage(`Your last transansction is Failed`);
        req.reject(409, "TRANSACTION_FAILED_INSIFFICIENT_BALANCE", [Id]);
      }
    }
    const commitresults =
      type == "deposit"
        ? await UPDATE(Accounts)
            .set("balance +=", amount)
            .where("accountid =", Id)
        : await UPDATE(Accounts)
            .set("balance -=", amount)
            .where("accountid =", Id)
            .and("balance >=", amount);
    if (commitresults == 0) {
      if (messageActive)
        await twilioClientMessage(`Your last transansction is failed`);
      req.reject(409, "TRANSACTION_FAILED");
    } else {
      await INSERT({
        accounts_accountid: Id,
        type,
        description,
        amount,
        date: new Date(),
      }).into(Transactions);
      const { balance } = await SELECT.one
        .from(Accounts, ["balance"])
        .where("accountid =", Id);
      const traMethod = type == "withdraw" ? "debited by" : "credit with";
      if (messageActive) {
        const message = await twilioClientMessage(
          `Your account #${Id} has ${traMethod} ${amount}Rs. and your current available balance is ${balance}Rs.`
        );
        message
          ? console.log(`Message ${message.sid} has been delivered.`)
          : console.error(message);
      }

      debug_customer(description, { Account: Id, amount: balance });
      log.info(description, { Account: Id, amount: balance });
    }
    req._.req.res.send("TRANSACTION_SUCCESS");
  } else {
    req.reject(409, `Please specify the trasaction type`);
  }
};

const twilioClientMessage = async (bodyMsg) => {
  await twilioClient.messages.create({
    body: bodyMsg,
    from: process.env.TWILIO_SENDER,
    to: process.env.TWILIO_RECEIVER,
  });
};

const fetchTransactionDetails = async (req) => {
  console.log(process.env.TWILIO_ACCOUNT_SID);
  debug_customer("Transaction customer ID", req.user.attr.ID);
  const { accountid } = await SELECT.one.from(Accounts, ["accountid"]).where({
    customers_custID: req.user.attr.ID[0], // setting the default user id as "202" for testing
  });

  const trasactionData = await SELECT.from(Transactions).where({
    accounts_accountid: accountid,
  });

  return trasactionData;
};

const setMessageDetails = async (req) => {
  const { confirmation, ID } = req.data;
  const affecteRows = await UPDATE(Customers)
    .set({ messageActive: confirmation })
    .where({ custID: ID });
  const sResMessage = affecteRows
    ? "Message Details updated Successfully"
    : "Could not update the message details";
  await twilioClientMessage(sResMessage);
  req._.req.res.send(sResMessage);
};

// Exposing the External API
const fetchAsteroidsDetails = async (req) => {
  const NeoWs = await cds.connect.to("NearEarthObjectWebService");
  try {
    const tx = NeoWs.transaction(req);
    return await tx.send({
      query: req.query,
    });
  } catch (err) {
    req.reject(err);
  }
};

module.exports = {
  _commitTransaction,
  fetchTransactionDetails,
  setMessageDetails,
  fetchAsteroidsDetails
};
