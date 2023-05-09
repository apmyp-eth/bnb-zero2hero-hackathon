task("transmitterAdd", "Add transmitter address to the aggregator")
  .addParam("aggregator" , "The aggregator's contract address")
  .addParam("transmitter", "The transmitter's address")
  .setAction(async (taskArgs) => {
    const abi = require("../artifacts/contracts/Aggregator.sol/Aggregator.json").abi;

    const [signer] = await ethers.getSigners();
    let aggregator = new ethers.Contract(taskArgs.aggregator, abi, signer);

    const transmitters = taskArgs.transmitter.split(',');
    for (const transmitter of transmitters) {
        await aggregator.transmitterAdd(transmitter);
    }
  }
);

task("transmitterDelete", "Delete transmitter address from the aggregator")
  .addParam("aggregator" , "The aggregator's contract address")
  .addParam("transmitter", "The transmitter's address")
  .setAction(async (taskArgs) => {
    const abi = require("../artifacts/contracts/Aggregator.sol/Aggregator.json").abi;

    const [signer] = await ethers.getSigners();
    let aggregator = new ethers.Contract(taskArgs.aggregator, abi, signer);

    const transmitters = taskArgs.transmitter.split(',');
    for (const transmitter of transmitters) {
        await aggregator.transmitterDelete(transmitter);
    }
  }
);
