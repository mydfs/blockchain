pragma solidity ^0.4.16;

interface Stats {
	function approve(address gameContract) external;
	function incStat(address user, bool win, uint256 entrySum, uint256 prize) external;
	function getFeePercent(address user) external constant returns (uint16 fee);
}