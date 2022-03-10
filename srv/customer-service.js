const cds = require('@sap/cds');
const handler = require("./handler");

module.exports = cds.service.impl((srv) => {
    srv.on('accountTransaction', handler.transaction._commitTransaction);
    srv.on("READ", "Transactions", handler.transaction.fetchTransactionDetails);
    srv.on("cancelMessage", handler.transaction.setMessageDetails)
});