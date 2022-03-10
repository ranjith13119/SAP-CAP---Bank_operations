module.exports = cds.service.impl(function() {
    this.before (['UPDATE'], 'Banks', _checkBankAuth)
  })

// Checking authorization
async function _checkBankAuth(req) {
    req.user.attr.bankID === req.data.bankID || req.reject(403, "You don't have the access for this data")
}