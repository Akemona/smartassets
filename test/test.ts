/* import { expect } from "chai";
import { ethers } from "hardhat";

describe("AkemonaERC20Perk", function () {
  it("Test contract", async function () {
    const ContractFactory = await ethers.getContractFactory("AkemonaERC20Perk");

    const defaultAdmin = (await ethers.getSigners())[0].address;
    const pauser = (await ethers.getSigners())[1].address;
    const minter = (await ethers.getSigners())[2].address;

    const instance = await ContractFactory.deploy(defaultAdmin, pauser, minter);
    await instance.waitForDeployment();

    expect(await instance.name()).to.equal("AkemonaERC20Perk");
  });
});
 */
