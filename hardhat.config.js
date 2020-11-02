// HardHat Config Settings

//const { projectId, mnemonic, apiKey } = require('./secrets.json');

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");

module.exports = {
    networks: {
        mainnet: {
          url: `ADD_YOUR_INFURA_LINK_HERE`,
          //accounts: {mnemonic: mnemonic}
        }
      },
      solidity: {
        version: "0.5.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
      },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: "ADD_YOUR_API_KEY_HERE"
      },
    solc: {
        version: "0.5.17"
      }
};