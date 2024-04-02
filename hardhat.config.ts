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
    polygonAmoy: {
      url: "https://rpc-amoy.polygon.technology",
    },
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY ?? "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY ?? "",
      sepolia: process.env.ETHERSCAN_API_KEY ?? "",
      polygonAmoy: process.env.OKLINK_API_KEY ?? "",
    },
    customChains: [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
          browserURL: "https://www.oklink.com/polygonAmoy",
        },
      },
    ],
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
