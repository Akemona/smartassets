// import { formatEther, parseEther } from "viem";
import hre from "hardhat";

async function main() {
  const contract = await hre.viem.deployContract("AkemonaERC20Perk", [
    "TOKENTEST",
    "SYMB",
    1000000000000n,
  ]);

  console.log(`AkemonaERC20Perk with name "TOKENTEST" ${contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
