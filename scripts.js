var Spot = artifacts.require("./Spot.sol");

module.exports = function(callback) {
	// var contractInstance = Spot.at('0xf12b5dd4ead5f743c6baa640b0216200e89b60da');
	Spot.new({
		from: '0x627306090abab3a6e1400e9345bc60c78a8bef57'
	}).then(contractInstance => {
		contractInstance.Load('0x345ca3e014aaf5dca488057592ee47305d9b3e10', 10, {
			from: '0x627306090abab3a6e1400e9345bc60c78a8bef57'
		}).catch(err => {
		    console.log('error', err);
		});
		var event = contractInstance.Loaded( {
			lender: '0x627306090abab3a6e1400e9345bc60c78a8bef57',
			token: '0x345ca3e014aaf5dca488057592ee47305d9b3e10'
		}, 
		{
			fromBlock: 0, 
			toBlock: 'latest',
			address: '0xf12b5dd4ead5f743c6baa640b0216200e89b60da'
		});

		event.get((error, logs) =>
		{
			logs.forEach(log => console.log(log.args))
		});
	}).catch(err => {
	    console.log('error', err);
	});	
}