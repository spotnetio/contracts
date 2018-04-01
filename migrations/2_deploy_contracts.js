var Spot = artifacts.require("./Spot.sol");
var WethToken = artifacts.require("./WethToken.sol");
var EosToken = artifacts.require("./EosToken.sol");
var VenToken = artifacts.require("./VenToken.sol");
var X1Token = artifacts.require("./X1Token.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Spot);
  deployer.deploy(WethToken, 1000000, {gas: 4000000});
  deployer.deploy(EosToken, 1000000, {gas: 4000000});
  deployer.deploy(VenToken, 1000000, {gas: 4000000});
  deployer.deploy(X1Token, 1000000, {gas: 4000000});
};