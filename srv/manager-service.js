const cds = require("@sap/cds");
const { Banks, Customers, Accounts } = cds.entities;
const log = require("cf-nodejs-logging-support");
log.setLoggingLevel("info");

module.exports = cds.service.impl((srv) => {
  srv.after("CREATE", "Banks", _afterCreationBank); // Just to print the created BankId

  srv.on("triggerAction", async (req) => {
    log.setSinkFunction("testing trigger action");
  });
  //Create a Event to update the Status to "Active"
  srv.on(["CREATE"], ["Banks", "Accounts", "Customers"], async (req) => {
    let payloadKey = {};
    const targetname = req.target.name.split(".")[1],
      { bankID, accountid, custID } = req.data;
    if (targetname == "Banks") {
      payloadKey = [{ ID: bankID, entity: targetname }];
    } else if (targetname == "Accounts") {
      payloadKey = [{ ID: accountid, entity: targetname }];
    } else {
      payloadKey = [{ ID: custID, entity: targetname }];
    }
    srv.emit("Bank/Account/Customer/Created", { payloadKey });
    console.log("<< Emitted Bank/Account/Customer/Created", { payloadKey });
  });

  // Listing the Event and Updating the status
  srv.on("Bank/Account/Customer/Created", async (msg) => {
    const tx = cds.tx(msg);
    if (msg.data.KEY[0].entity == "Banks") {
      const affectedrows = await tx.run(
        UPDATE(Banks)
          .set({ status: "Active" })
          .where("bankID =", msg.data.KEY[0].ID)
      );
      if (affectedrows == 0) {
        console.log(
          `Status of Bank ${msg.data.KEY[0].ID} could not be updated`
        );
        return;
      }
      let customercount = await tx.run(
        SELECT.from(Customers).where("bank_bankID =", msg.data.KEY[0].ID)
      );
      if (customercount.length) {
        const affectedcustomerrows = await tx.run(
          UPDATE(Customers)
            .set({ status: "Active" })
            .where("bank_bankID =", msg.data.KEY[0].ID)
        );
        if (affectedcustomerrows == 0) {
          console.log(
            `Status of all the customers in Bank ${msg.data.KEY[0].ID} could not be updated`
          );
          return;
        }
        console.log(
          `Status of Bank Id ${msg.data.KEY[0].ID} and its customers are updated successfully`
        );
      } else {
        console.log(
          `Status of Bank Id ${msg.data.KEY[0].ID} updated successfully`
        );
      }
    } else if (msg.data.KEY[0].entity == "Accounts") {
      const affectedrows = await tx.run(
        UPDATE(Accounts)
          .set({ account_status: "Active" })
          .where("accountid =", msg.data.KEY[0].ID)
      );
      const sMessage = affectedrows
        ? `Status of Accounts Id ${msg.data.KEY[0].ID} updated successfully`
        : `Status of Accounts Id ${msg.data.KEY[0].ID} could not be updated`;
      console.log(sMessage);
    } else {
      const affectedcustomerrows = await tx.run(
        UPDATE(Customers)
          .set({ status: "Active" })
          .where("custID =", msg.data.KEY[0].ID)
      );
      if (affectedcustomerrows == 0) {
        console.log(
          `Status of Customer ${msg.data.KEY[0].ID} could not be updated`
        );
        return;
      }
      const accountCount = await tx.run(
        SELECT.from(Accounts).where("customers_custID=", msg.data.KEY[0].ID)
      );
      if (accountCount.length) {
        const affectedAccountrows = await tx.run(
          UPDATE(Accounts)
            .set({ account_status: "Active" })
            .where("customers_custID=", msg.data.KEY[0].ID)
        );
        if (affectedAccountrows == 0) {
          console.log(
            `Status of customer's accounts ${msg.data.KEY[0].ID} could not be updated`
          );
          return;
        }
        console.log(
          `Status of Customer Id ${msg.data.KEY[0].ID} and his accounts are updated successfully`
        );
      } else {
        console.log(
          `Status of CustomerId ${msg.data.KEY[0].ID} is updated successfully`
        );
      }
    }
  });
});

async function _afterCreationBank(bankdetails, req) {
  await bankdetails.customers.array.forEach((cust) => {
    console.log(`Customer ${cust.custID} is Created`);
    cust.accounts.forEach((acc) => {
      console.log(`Account ${acc.accountid} is Created`);
      acc.transactions.forEach((tra) => {
        console.log(`Transaction ${tra.ID} is Created`);
      });
    });
  });
}
