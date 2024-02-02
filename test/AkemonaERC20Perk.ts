import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress, parseGwei } from "viem";

describe("AkemonaERC20Perk", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  /*  async function deployOneYearAkemonaERC20PerkFixture() {


    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.viem.getWalletClients();

    // fix params
    const lock = await hre.viem.deployContract("AkemonaERC20Perk", [], {
    });

    const publicClient = await hre.viem.getPublicClient();

    return {
      owner,
      otherAccount,
      publicClient,
    };
  } */

  describe("Deployment", function () {
    it("test", async function () {});
  });
});
