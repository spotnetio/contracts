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
      network_id: "4447",
      // gas: 2000000,
    },
    private: {
      host: "localhost",
      port: 8545,
      network_id: "4224",
      gas: 4700000
    }
  }
};
