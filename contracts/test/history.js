/**
 * DISCLAIMER: This is NOT Hardhat tests as their expected to be!
 * This is script to check that getBatchHistoryPrice works
 */

const { ethers } = require("hardhat");
const { expect } = require("chai");

async function makeSignature(roundId, timestamp, price, signer) {
    let payload = ethers.utils.defaultAbiCoder.encode([ "uint", "uint", "uint" ], [ roundId, timestamp, price ]);
    //console.log("Payload:", payload);

    let payloadHash = ethers.utils.keccak256(payload);
    //console.log("PayloadHash:", payloadHash);

    let signature = await signer.signMessage(ethers.utils.arrayify(payloadHash));
    let sig = ethers.utils.splitSignature(signature);

    //console.log("Signature:", sig);
    //console.log("Recovered:", ethers.utils.verifyMessage(ethers.utils.arrayify(payloadHash), sig));
    //console.log(`Sig vrs (${sig.v}, ${sig.r}, ${sig.s})`);

    return sig;
}

function timestamp() { let now = Date.now(); return Math.floor(now/1000); }
  
describe("History Tests", async function () {
    let   deployer, heartbit, transmitter, client;
    let   oracle, aggregator, symbol;
    const symbolCode=0;
    
    it("Fill the history and then simulate frontend calls", async function () {
        console.log("+-------------+--------------------------------------------+");
        // Initialize accounts
        [deployer,heartbit,transmitter,client] = await ethers.getSigners();
    
        // Deploy PriceOracle
        const oracleFactory = await ethers.getContractFactory("PriceOracle");
        oracle = await oracleFactory.deploy();
        await oracle.deployed();
        console.log(`| PriceOracle | ${oracle.address} |`);
    
        // Deploy symbol and aggregator
        const aggregatorFactory = await ethers.getContractFactory("Aggregator");
        aggregator = await aggregatorFactory.deploy(heartbit.address,1);
        await aggregator.deployed();
        console.log(`| Aggregator  | ${aggregator.address} |`);
    
        const symbolFactory = await ethers.getContractFactory("Symbol");
        symbol = await symbolFactory.deploy("GOLD", 2, aggregator.address);
        await symbol.deployed();
        await aggregator.setSymbol(symbol.address);
        await aggregator.transmitterAdd(transmitter.address);
        console.log(`| Symbol      | ${symbol.address} |`);
    
        oracle.symbolAddOrUpdate(symbolCode, symbol.address);
        console.log("+-------------+--------------------------------------------+\n");

        // Fill the history
        for(var roundId=0; roundId<10; roundId++) {
            const now = timestamp();
            const price = Math.floor((Math.random()*now)%100000);
            // start round
            await aggregator.connect(heartbit).startRound();

            const sig = await makeSignature(roundId, now, price, transmitter);
            await aggregator.connect(transmitter).transmit(roundId, now, price, sig.v, sig.r, sig.s);

            // stop round
            await aggregator.connect(heartbit).stopRound();
        }

        // Frontend: symbol config
        const tsStart=Date.now();
        const name = await oracle.connect(client).symbolName(symbolCode);
        console.log(`Symbol name   : ${name}`)
        const digits = await oracle.connect(client).symbolDigits(symbolCode);
        console.log(`Symbol digits : ${digits}`)

        let [lastRoundId, ] = await oracle.connect(client).getLastPrice(symbolCode);
        console.log(`Last round ID : ${lastRoundId}`);

        let [prices, total] = await oracle.connect(client).getBatchHistoryPrice(symbolCode, lastRoundId, 100);
        console.log(`Total prices  : ${total}\n`)

        for(var i=0; i<total; i++) {
            console.log(`${prices[i].timestamp} : ${prices[i].price}`)
        }

        console.log(`Frontend finished in ${Date.now()-tsStart} ms`)

        // THE END
        console.log("\n\n");
    })
});
