var Spot = artifacts.require("./Spot.sol");
var EosToken = artifacts.require("./EosToken.sol");
var WethToken = artifacts.require("./WethToken.sol");


function log(obj) {
	console.log(obj);
}

contract('Approve 10 EOS & Weth tokens, lock and buy to cover', function(accounts){
	var lender1 = accounts[0];
	var borrower1 = accounts[1];
	var lender2 = accounts[2];
	var borrower2 = accounts[3];
	var spotInstance;
	var eosTokenInstance;
	var wethTokenInstance;

	it("should approve spotnet for 10 EOS tokens", function() {
		return EosToken.deployed().then(function(instance) {
			eosTokenInstance = instance;
			log(eosTokenInstance.address);
			return Spot.deployed();
		}).then(function(instance) {
			spotInstance = instance;
			return WethToken.deployed();
		}).then(function(instance) {
			wethTokenInstance = instance;
			eosTokenInstance.approve(spotInstance.address, 10, {from: lender1});
			return eosTokenInstance.allowance(lender1, spotInstance.address);
		}).then(function(data) {
			assert.equal(data, 10, "eos allowance amount should be " + 10);
			wethTokenInstance.approve(spotInstance.address, 10, {from: borrower1});
			return wethTokenInstance.allowance(borrower1, spotInstance.address);
		}).then(function(data) {
			assert.equal(data, 10, "weth allowance amount should be " + 10);
		});
	});

	it("should lock", function() {
		return spotInstance.Lock( 
			lender1, 
			borrower1,
			eosTokenInstance.address,
			10,
			100,
			0,
			10000,
			{from: borrower1}
		).then(function(data) {
			return spotInstance.getLock(lender1, 0);
		}).then(function(data) {
			assert.equal(data[3], 10, "amount of locked Eos should be 10");
			assert.equal(data[4], 10, "amount of locked Ether should be 10");
			return wethTokenInstance.balanceOf(borrower1);
		}).then(function(data) {
			assert.equal(data, 10, "borrower should have 10 Eos");
			return WethToken.balanceOf(borrower1);
		});
	});

	// it("should buy to cover", function() {
	// 	x1TokenInstance.approve(
	// 		spotInstance.address, 
	// 		10, 
	// 		{from: borrower1});
	// 	return x1TokenInstance.allowance(
	// 		borrower1, 
	// 		spotInstance.address
	// 	).then(function(data) {
	// 		assert.equal(data, 10, "allowance amount should be " + 10);
	// 		return spotInstance.BuyToCover(
	// 			x1TokenInstance.address, 
	// 			100,
	// 			0,
	// 			10000,
	// 			{from: borrower1});
	// 	}).then(function(data) {
	// 		return spotInstance.getLock(
	// 			x1TokenInstance.address, 
	// 			lender1, 
	// 			borrower1);
	// 	}).then(function(data) {
	// 		assert.equal(data[0], 0, "amount of locked X1 should be 0");
	// 		assert.equal(data[1], 0, "amount of locked Ether should be 0");
	// 		assert.equal(web3.eth.getBalance(spotInstance.address), 0, "this contract shoul have 0 balance of Ether");
	// 		return x1TokenInstance.balanceOf(borrower1);
	// 	}).then(function(data) {
	// 		assert.equal(data, 0, "borrower should have 0 X1");
	// 	});
	// });
});

// contract('Approve 10 X1 tokens, lock and swap lenders', function(accounts){
// 	var lender1 = accounts[0];
// 	var borrower1 = accounts[1];
// 	var lender2 = accounts[2];
// 	var borrower2 = accounts[3];
// 	var spotInstance;
// 	var x1TokenInstance;

// 	it("should approve spotnet for 10 X1 tokens", function() {
// 		return X1Token.deployed().then(function(instance) {
// 			x1TokenInstance = instance;
// 			return Spot.deployed();
// 		}).then(function(instance) {
// 			spotInstance = instance;
// 			x1TokenInstance.approve(spotInstance.address, 10, {from: lender1});
// 			return x1TokenInstance.allowance(lender1, spotInstance.address);
// 		}).then(function(data) {
// 			assert.equal(data, 10, "allowance amount should be " + 10);
// 		});
// 	});

// 	it("should lock", function() {
// 		return spotInstance.Lock(
// 			x1TokenInstance.address, 
// 			lender1, 
// 			100,
// 			0,
// 			10000,
// 			{from: borrower1, value: 10}
// 		).then(function(data) {
// 			return spotInstance.getLock(x1TokenInstance.address, lender1, borrower1);
// 		}).then(function(data) {
// 			assert.equal(data[0], 10, "amount of locked X1 should be 10");
// 			assert.equal(data[1], 10, "amount of locked Ether should be 10");
// 			assert.equal(web3.eth.getBalance(spotInstance.address), 10, "this contract shoul have 10 balance of Ether");
// 			return x1TokenInstance.balanceOf(borrower1);
// 		}).then(function(data) {
// 			assert.equal(data, 10, "borrower should have 10 X1");
// 		});
// 	});

// 	it("should swap lenders", function() {
// 		// Fund lender2
// 		x1TokenInstance.transfer(
// 			lender2, 
// 			10, 
// 			{from: lender1});
// 		x1TokenInstance.approve(
// 			spotInstance.address, 
// 			10, 
// 			{from: lender2});
// 		return x1TokenInstance.balanceOf(
// 			lender2
// 		).then(function(data) {
// 			assert.equal(data, 10, "lender2 X1 balance should be " + 10);
// 			return spotInstance.SwapLenders(
// 				x1TokenInstance.address, 
// 				[lender2],
// 				100,
// 				0,
// 				10000,
// 				{from: lender1});
// 		}).then(function(data) {
// 			return spotInstance.getLock(
// 				x1TokenInstance.address, 
// 				lender2, 
// 				borrower1);
// 		}).then(function(data) {
// 			assert.equal(data[0], 10, "amount of locked X1 should be 10");
// 			assert.equal(data[1], 10, "amount of locked Ether should be 10");
// 			return spotInstance.getLock(
// 				x1TokenInstance.address, 
// 				lender1, 
// 				borrower1);
// 		}).then(function(data) {
// 			assert.equal(data[0], 0, "amount of locked X1 should be 0");
// 			assert.equal(data[1], 0, "amount of locked Ether should be 0");
// 		});
// 	});
// });




