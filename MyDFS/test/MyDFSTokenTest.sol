pragma solidity ^0.4.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MyDFSToken.sol";

contract MyDFSTokenTest{

	function testInitialBalance() external {
		MyDFSToken token = MyDFSToken(DeployedAddresses.MyDFSToken());

		uint expected = 100000;

		Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 100000 tokens initially");
	}

	// function testTransferBalance() external {
	// 	MyDFSToken token = MyDFSToken(DeployedAddresses.MyDFSToken());

	// 	token.transfer(address(0x627306090abab3a6e1400e9345bc60c78a8bef57), 10000);

	// 	uint expected = 90000;

	// 	Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 100000 tokens initially");
	// }

	// function testIncreaseApprovalBalance() external {
	// 	MyDFSToken token = MyDFSToken(DeployedAddresses.MyDFSToken());

	// 	uint expected = 100000;

	// 	Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 100000 tokens initially");
	// }

	// function testDecreaseApprovalBalance() external {
	// 	MyDFSToken token = MyDFSToken(DeployedAddresses.MyDFSToken());

	// 	uint expected = 100000;

	// 	Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 100000 tokens initially");
	// }

	// function testTransferFromBalance() external {
	// 	MyDFSToken token = MyDFSToken(DeployedAddresses.MyDFSToken());

	// 	uint expected = 100000;

	// 	Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 100000 tokens initially");
	// }

}