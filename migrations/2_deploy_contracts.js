var Spot = artifacts.require("./Spot.sol");
var BNB = artifacts.require("./BNB.sol");
var EOS = artifacts.require("./EOS.sol");
var TRX = artifacts.require("./TRX.sol");
var ZeroX = artifacts.require("./ZeroX.sol");
var Weth = artifacts.require("./Weth.sol");

module.exports = function(deployer, network, accounts) {
	deployer.deploy(EOS, 1000000, {gas: 4000000});
	deployer.deploy(TRX, 1000000, {gas: 4000000});
	deployer.deploy(ZeroX, 1000000, {gas: 4000000});
	deployer.deploy(BNB, 1000000, {gas: 4000000});
	deployer.deploy(Weth, 1000000, {gas: 4000000}).then(async function() {
		let weth = await Weth.deployed();
		await deployer.deploy(Spot, weth.address, {gas: 4000000});
	});
};