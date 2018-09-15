var HDWalletProvider = require("truffle-hdwallet-provider");
var config = require("./secrets.js").config;

// migrate --compile-all --reset
// Spot.deployed().then(function(i){s=i;})

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  // networks: {
  //   ganache: {
  //     host: "localhost",
  //     port: 7545,
  //     network_id: "*"
  //   }
  // }
  networks: {
    develop: {
      host: "localhost",
      port: 9545,
      network_id: "*",
      // network_id: "4447",
      // gas: 2000000,
    },
    private: {
      host: "localhost",
      port: 8545,
      network_id: "4224",
      gas: 4700000
    },
    // ropsten: {
    //   provider: new HDWalletProvider(config["mnemonic"]["ropsten"], "https://ropsten.infura.io/"+config["infura_apikey"]),
    //   network_id: 3,
    //   gas: 2000000,//4712388,
    //   // gasPrice: 50000000000
    // },
  }
};
