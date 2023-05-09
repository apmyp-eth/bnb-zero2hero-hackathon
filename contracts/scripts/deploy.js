const { ethers, run, network } = require("hardhat");

async function main() {
  const chainId = parseInt(await network.provider.send('eth_chainId'));
  const [signer] = await ethers.getSigners();
  const symbols = [
    { code: 0, name: "GOLD"  , digits: 2 },
    { code: 1, name: "BRENT" , digits: 2 },
    { code: 2, name: "USDKZT", digits: 2 },
  ];
  let deployments = [];
  let contracts = [];

  // Deploy PriceOracle
  const oracleFactory = await ethers.getContractFactory("PriceOracle");
  const oracle = await oracleFactory.deploy();
  await oracle.deployed();
  console.log(`PriceOracle contract : ${oracle.address}`);
  contracts.push({ address: oracle.address, type: "oracle", args: [] }); // no arguments for deploy

  // Deploy symbol and aggregator contracts for each symbol
  for (const symbol of symbols) {
    var deployment = { name: symbol.name };

    const aggregatorFactory = await ethers.getContractFactory("Aggregator");
    const aggregator = await aggregatorFactory.deploy(process.env.HEARTBIT_ADDRESS,1);
    await aggregator.deployed();
    contracts.push({ address: aggregator.address, type: "aggregator", args: [process.env.HEARTBIT_ADDRESS,1] });
    deployment.aggregator=aggregator.address;

    const symbolFactory = await ethers.getContractFactory("Symbol");
    const symbolContract = await symbolFactory.deploy(symbol.name, symbol.digits, aggregator.address);
    await symbolContract.deployed();
    contracts.push({ address: symbolContract.address, type: "symbol", args: [symbol.name, symbol.digits, aggregator.address] });
    deployment.symbol=symbolContract.address;

    await aggregator.setSymbol(symbolContract.address);
    await oracle.symbolAddOrUpdate(symbol.code, symbolContract.address);
    deployments[symbol.code]=deployment;
  }

  Object.entries(deployments).forEach(([code, deployment]) => {
    console.log(`#${code}, ${deployment.name}:`)
    console.log(`\tsymbol       : ${deployment.symbol}`);
    console.log(`\taggregator   : ${deployment.aggregator}`);
  })

  // verify only for BNB Chain Testnet
  if(process.env.VERIFY_CONTRACTS && chainId==97) {
    console.log("\nVerifying contracts:\n");

    await Promise.all(contracts.map( async (contract) => {
      var res = await verify(contract.address, contract.args) ? "\033[32mOK \033[0m ":"\033[31mERR\033[0m ";
      console.log(`${contract.address}: `+ res + `${contract.type} with args ` + JSON.stringify(contract.args));
    }));
  }
}

async function verify(contractAddress, arguments) {
  try {
    await run("verify:verify", { address: contractAddress, constructorArguments: arguments });
    return true;
  }
  catch(e) {
    if(e.message.toLowerCase.includes("already verified")) {
      //console.log("The contract already verified");
      return true;
    }
    else {
      console.log(e);
    }
  }

  return false;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
