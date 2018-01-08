pragma solidity ^0.4.16;

interface BalanceManager {

	function deposit(uint32 sum) external; 
	function depositTo(address to, uint32 sum) external;
	function withdraw(uint32 sum) external;
	function balanceOf(address user) public constant returns (uint32);
}