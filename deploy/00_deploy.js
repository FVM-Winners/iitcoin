require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")

const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    console.log("Wallet Ethereum Address:", wallet.address)
    const chainId = network.config.chainId
    const tokensToBeMinted = networkConfig[chainId]["tokensToBeMinted"]

    //deploy PriceOracle
    const PriceOracle = await ethers.getContractFactory("PriceOracle", wallet)
    console.log("Deploying PriceOracle...")
    const priceOracle = await PriceOracle.deploy(wallet.address)
    await priceOracle.deployed()
    console.log("PriceOracle deployed to:", priceOracle.address)
    // deployed at 0x9E01a4Ab9dc8871d216120f11bEDdA7a6934F780

    //deploy Dia
    const IITStableCoin = await ethers.getContractFactory("IITStableCoin", wallet)
    console.log("Deploying IIT...")
    const IIT = await IITStableCoin.deploy()
    await IIT.deployed()
    console.log("IITStableCoin deployed to:", IIT.address)
    // deployed at 0x4F55a87a706e063f37CaE1bAEE9065d42d440ab7
}
