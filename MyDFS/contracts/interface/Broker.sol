pragma solidity ^0.4.16;

interface Broker {

	function transferFrom(address beneficiary, address user, address to, uint256 value) external returns (bool success);
	function getUserFee(address beneficiary, address user) external constant returns (uint16 fee);

	function allowance(address owner, address spender) public constant returns (uint256 remaining);
	
}