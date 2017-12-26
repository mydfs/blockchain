pragma solidity ^0.4.16;

import './interface/Stats.sol';

contract UserStats is Stats {

	struct User {
		uint256 gamesCount;
		uint256 wins;
		uint256 totalPrizeSum;
		uint256 totalLoseSum;
		uint16 feePercent;
	}

	mapping(address => User) public users;
	mapping(address => bool) public gameAddresses;

	address public owner;

	modifier allowed() { require(gameAddresses[msg.sender]); _; }
	modifier owned() { require(msg.sender == owner); _; }

	function UserStats() public {
		owner = msg.sender;
	}

	function approve(
		address gameContract
	) 
		external
		owned
	{
		gameAddresses[gameContract] = true;
	}

	function incStat(
		address user, 
		bool win, 
		uint256 entrySum, 
		uint256 prize
	)
		external
		allowed
	{
		users[user].gamesCount++;
		if (win){
			users[user].wins++;
		}
		users[user].totalPrizeSum += prize;
		users[user].totalLoseSum += entrySum;
	}

	function changeFeePercent(uint16 amount) external {
		require(amount >= 0 && amount <= 100);
		users[msg.sender].feePercent = amount;
	}

	function getFeePercent(
		address user
	)
		external
		constant
		returns (uint16 fee)
	{
		return users[user].feePercent;
	}

	function allowance(address game) external constant returns (bool) {
		return gameAddresses[game];
	}

}