# Table of Contents
- [Install](#Install)
- [Execution](#Execution) 
- [License](#License)

# Install
you need to install `foundry`

# Execution
```bash
// make account with 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
cast wallet import --interactive testAccount

// run virtual EVM blockchain
anvil

cd AMM
// deploy AMM, PriceFeed, Tokens
// deploy contracts and copy contracts address to .env file
forge script script/Tokens.s.sol:TokensScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge script script/PriceFeed.s.sol:PriceFeedScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge script script/DeployAmm.s.sol:DeployAmmScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge script script/ControlAmm.s.sol:ControlAmmScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

cd ..
cd DEX
forge script script/DeployDex.s.sol:DeployDexScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

cd ..
cd goApp
// copy contract addresses to .env file
// execute main binary to write price data to PriceFeed contract
./main

// test DEX libaries
cd ..
cd DEX
forge test -vv
```

# License
MIT
