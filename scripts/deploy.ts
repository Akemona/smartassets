// import { formatEther, parseEther } from "viem";
import hre from "hardhat";

async function main() {
  const contract = await hre.viem.deployContract("AkemonaERC20Perk", [
    "TOKENTEST",
    "SYMB",
    1000000000000n,
    100000000n,
    "0x6B9a53d301b62441c30f56b887f1f7b8C191ac0a",
    "0x18e841104b12D887D20499302b19454b4F43154A",
  ]);

  console.log(`AkemonaERC20Perk with name "TOKENTEST" ${contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
