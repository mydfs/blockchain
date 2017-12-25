pragma solidity ^0.4.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MyDFSToken.sol";

contract TestMyDFSToken{

	MyDFSToken token;

	address firstAddress;
	address secondAddress;
	address thirdAddress;

	uint firstBeforeBalance;
	uint secondBeforeBalance;
	uint thirdBeforeBalance;

	uint value = 10000;

	function beforeAll(){
		firstAddress = address(this);
		secondAddress = 0xf17f52151ebef6c7334fad080c5704d77216b732;
		thirdAddress = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
	}

	function testInitialBalance() external {
		token = new MyDFSToken();

		uint expected = 100000;

		Assert.equal(token.balanceOf(firstAddress), expected, "Owner should have 100000 tokens initially");
	}

	function testTransferBalance() external {
		firstBeforeBalance = token.balanceOf(firstAddress);
		secondBeforeBalance = token.balanceOf(secondAddress);

		token.transfer(secondAddress, value);

		Assert.equal(token.balanceOf(firstAddress), firstBeforeBalance - value, "first should have balance - 10000 tokens");
		Assert.equal(token.balanceOf(secondAddress), secondBeforeBalance + value, "second should have balance + 10000 tokens");
	}
	
	//need to send from thirdAddress  HOW TO????
	
	function testIncreaseApprovalBalance() external {
		token.increaseApproval(thirdAddress, value);

		firstBeforeBalance = token.balanceOf(firstAddress);
		thirdBeforeBalance = token.balanceOf(thirdAddress);

		token.transferFrom(firstAddress, thirdAddress, value);

		Assert.equal(token.allowance(firstAddress, thirdAddress), value, "allowance is 10000 tokens");
		Assert.equal(token.balanceOf(firstAddress), firstBeforeBalance - value, "first should have balance - 10000 tokens");
		Assert.equal(token.balanceOf(thirdAddress), thirdBeforeBalance + value, "third should have balance + 10000 tokens");
	}

	function testTransferFromDeniedBalance() external {
		token.increaseApproval(thirdAddress, value);

		firstBeforeBalance = token.balanceOf(firstAddress);
		thirdBeforeBalance = token.balanceOf(thirdAddress);

		token.transferFrom(firstAddress, thirdAddress, value * 2);

		Assert.equal(token.allowance(firstAddress, thirdAddress), value, "allowance is 10000 tokens");
		Assert.equal(token.balanceOf(firstAddress), firstBeforeBalance, "first should have balance without changes");
		Assert.equal(token.balanceOf(thirdAddress), thirdBeforeBalance, "third should have balance without changes");
	}

	function testDecreaseApprovalBalance() external {
		token.decreaseApproval(thirdAddress, value);

		firstBeforeBalance = token.balanceOf(firstAddress);
		thirdBeforeBalance = token.balanceOf(thirdAddress);

		token.transferFrom(firstAddress, thirdAddress, value);

		Assert.equal(token.allowance(firstAddress, thirdAddress), 0, "allowance is 0 tokens");
		Assert.equal(token.balanceOf(firstAddress), firstBeforeBalance, "first should have balance without changes");
		Assert.equal(token.balanceOf(thirdAddress), thirdBeforeBalance, "third should have balance without changes");
	}

}