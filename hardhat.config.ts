import "dotenv/config";
import type { HardhatUserConfig } from "hardhat/config";

import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable } from "hardhat/config";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import { polygonAmoy } from "viem/chains";

const config: HardhatUserConfig = {
  plugins: [hardhatToolboxViemPlugin, hardhatVerify],
  solidity: {
    profiles: {
      default: {
        version: "0.8.27",
      },
      production: {
        version: "0.8.27",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY,
    },
  },
  chainDescriptors: {
    [polygonAmoy.id]: {
      name: polygonAmoy.name,
      blockExplorers: {
        etherscan: polygonAmoy.blockExplorers.default,
      },
    },
  },
};

export default config;
