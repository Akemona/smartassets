import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

const config: HardhatUserConfig = {
  sourcify: {
    enabled: true,
  },
  networks: {
    hardhat: {},
    polygonMumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
    },
    sepolia: {
      url: "https://rpc.sepolia.org",
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGONSCAN_API_KEY ?? "",
      sepolia: process.env.ETHERSCAN_API_KEY ?? "",
    },
  },
  solidity: {
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 15000,
      },
      evmVersion: `paris`,
    },
  },
};

export default config;
