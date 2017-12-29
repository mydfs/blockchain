pragma solidity ^0.4.16;

interface BalanceManager {

	function deposit(uint sum) external; 
	function depositTo(address to, uint sum) external;
	function withdraw(uint256 sum) external;
	function balanceOf(address user) public constant returns (uint256);
}