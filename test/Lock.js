
const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("FlashLoan", function () {
  let Token, token, FlashLoan, flashloan, FlashLoanReciever, flashloanreciever
  const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), "ether");
  }
  beforeEach(async function () {
    [acc1, acc2] = await ethers.getSigners();

    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy("DEH", "DeHeritage", '1000000');
    await token.deployed();

    FlashLoan = await ethers.getContractFactory("FlashLoan");
    flashloan = await FlashLoan.deploy(token.address);
    await flashloan.deployed();

    FlashLoanReciever = await ethers.getContractFactory("FlashLoanReciever");
    flashloanreciever = await FlashLoanReciever.deploy(flashloan.address)
    await flashloanreciever.deployed();

    let transaction = await token.connect(acc1).approve(flashloan.address, tokens(1000000));
    await transaction.wait();

    transaction = await flashloan.connect(acc1).depositTokens(tokens(1000000));
    await transaction.wait();
  })
  describe("deployment", async () => {

    it("should deposit tokens to the flashloan contract", async () => {
      expect(await token.balanceOf(flashloan.address)).to.equal(tokens(1000000));
    })
  })
  describe("borrowing funds", async () => {
    it("should borrow funds from the pool", async () => {
      let amount = tokens(100);
      let transaction = await flashloanreciever.connect(acc1).executeFlashLoan(amount);
      await transaction.wait()

      expect(transaction).to.emit(flashloanreciever, "LoanRecieved").withArgs(token.address, amount);
    })
  })


})
