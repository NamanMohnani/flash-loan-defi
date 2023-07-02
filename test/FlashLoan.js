const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("FlashLoan", () => {
  let token, flashLoan, flashLoanReceiver;
  let deployer, accounts;

  beforeEach(async () => {
    // get accounts
    accounts = await ethers.getSigners(); //  array
    deployer = accounts[0]; // first account in accounts

    // load accounts
    const Token = await ethers.getContractFactory("Token");
    const FlashLoan = await ethers.getContractFactory("FlashLoan");
    const FlashLoanReceiver = await ethers.getContractFactory(
      "FlashLoanReceiver"
    );

    // deploy token
    token = await Token.deploy("berries", "BER", 1000000);

    // deploy FlashLoan pool
    flashLoan = await FlashLoan.deploy(token.address);

    // approve tokens before depositing
    let transaction = await token
      .connect(deployer)
      .approve(flashLoan.address, tokens(1000000));
    await transaction.wait();

    // deposit tokens into the pool
    transaction = await flashLoan
      .connect(deployer)
      .depositTokens(tokens(1000000));
    await transaction.wait();

    // deploy the flash loan reciever
    flashLoanReceiver = await FlashLoanReceiver.deploy(flashLoan.address);
  });

  describe("deployment", () => {
    it(" sends token to the flash loan pool contract", async () => {
      expect(await token.balanceOf(flashLoan.address)).to.equal(
        tokens(1000000)
      );
    });
  });

  describe("borrowing funds", () => {
    it("borrow funds from the pool", async () => {
      let amount = tokens(100);
      let transaction = await flashLoanReceiver
        .connect(deployer)
        .executeFlashLoan(amount);
      let result = await transaction.wait();

      await expect(transaction)
        .to.emit(flashLoanReceiver, "LoanRecieved")
        .withArgs(token.address, amount);
    });
  });
});
