const cds = require('@sap/cds');
const handler = require("./handler");

class Customer extends cds.ApplicationService {
    init() {
        // const { Transactions } = this.entities;
        this.on('accountTransaction', handler.transaction._commitTransaction);
        this.on("READ", "Transactions", handler.transaction.fetchTransactionDetails);
        this.on("cancelMessage", handler.transaction.setMessageDetails);
        this.on("READ", "Asteroids", handler.transaction.fetchAsteroidsDetails);
        return super.init();
    }
};

module.exports = {
    Customer
};