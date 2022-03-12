// Checking authorization
async function _checkBankAuth(req) {
  req.user.attr.bankID === req.data.bankID ||
    req.reject(403, "You don't have the access for this data");
}

class EmployeeService extends cds.ApplicationService {
  init() {
    this.before(["UPDATE"], "Banks", _checkBankAuth);
    return super.init();
  }
}

module.exports = {
  EmployeeService,
};
