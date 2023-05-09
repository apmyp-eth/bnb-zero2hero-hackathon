const { ethers } = require('ethers');
const { abi } = require('./abi');
require('dotenv').config();
var CronJob = require('cron').CronJob;

// parse aggregators addresses
const aggregators = process.env.AGGREGATORS.split(' ');
// initialize network
const provider    = new ethers.providers.JsonRpcProvider(process.env.RPC_URI);
const signer      = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// helper
function timestamp() {
    let now = Date.now();
    return Math.floor(now/1000);
}

// start/stop round
async function roundStart(aggregatorAddress) {
    let aggregator = new ethers.Contract(aggregatorAddress, abi, signer);
    let tx = await aggregator.startRound();

    console.log(`${aggregatorAddress} ${timestamp()}: Round start with tx ${tx.hash}`);
    await tx.wait();
}

async function roundStop(aggregatorAddress) {
    let aggregator = new ethers.Contract(aggregatorAddress, abi, signer);
    let tx = await aggregator.stopRound();

    console.log(`${aggregatorAddress} ${timestamp()}: Round stop with tx ${tx.hash}`);
    await tx.wait();
}

async function round() {
    for (const aggregator of aggregators) {
        await roundStart(aggregator);
    }

    setTimeout(async ()=> {
        for (const aggregator of aggregators) {
            await roundStop(aggregator);
        }
    }, 35*1000);
}

// cron job for periodic execution
var job = new CronJob(
    '0 */5 * * * *',
    function() {
        round()
    },
    null,
    true
);
