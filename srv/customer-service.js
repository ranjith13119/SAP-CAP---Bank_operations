const cds = require('@sap/cds');
const {transaction} = require("./handler");

class Customer extends cds.ApplicationService {
    init() {
        // const { Transactions } = this.entities;
        this.on('accountTransaction', transaction._commitTransaction);
        this.on("READ", "Transactions", transaction.fetchTransactionDetails);
        this.on("cancelMessage", transaction.setMessageDetails);
        this.on("READ", "Asteroids", transaction.fetchAsteroidsDetails);
        return super.init();
    }
};

module.exports = {
    Customer
};