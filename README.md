# @uniswap/liquidity-staker

# Description
Open Source Factory for liquidity mining

# Quick Start
Hardhat is used through a local installation in your project. This way your environment will be reproducible, and you will avoid future version conflicts.

Once your project is ready, you should run

```
npm install --save-dev hardhat

```

This plugin brings to Hardhat the Ethereum library ethers.js, which allows you to interact with the Ethereum blockchain in a simple way.

```
npm install --save-dev @nomiclabs/hardhat-ethers 'ethers@^5.0.0'

```

This plugin helps you verify the source code for your Solidity contracts on Etherscan.

It's smart and it tries to do as much as possible to facilitate the process. Just provide the deployment address and constructor arguments, and the plugin will detect locally which contract to verify.

```
npm install --save-dev @nomiclabs/hardhat-etherscan

```

To use your local installation of Hardhat, you need to use npx to run it  

```
npx hardhat

```

To compile it, simply run the following command:

```
npx hardhat compile

```

# Testing 

You can run your tests with wiht the following command: 

```
npx hardhat test

```

# Deployment 

Deploy your contracts in the following method

```
npx hardhat run --network <your-network> scripts/sample-script.js

```

# Truffle migrations support
You can use Hardhat alongside Truffle if you want to use its migration system. Your contracts written using Hardhat will just work with Truffle.

All you need to do is installing Truffle, and follow their [Migrations guide](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations).

# More Information

For more information please visit HardHats [Official Site](https://hardhat.org/) for more documentation

# Notable Mentions
Special thank to the [Sparkle Loyalty Community](https://t.me/Sparkleloyalty) for contributing on this project.  

Forked from 
[https://github.com/Synthetixio/synthetix/tree/v2.27.2/](https://github.com/Synthetixio/synthetix/tree/v2.27.2/)
