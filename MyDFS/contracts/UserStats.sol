pragma solidity ^0.4.16;

import './interface/Stats.sol';

contract UserStats is Stats {

	struct User {
		uint16 commandsCount;
		uint16 wins;
		uint32 totalPrizeSum;
		uint32 totalLoseSum;
		uint8 feePercent;
	}

	mapping(address => User) public users;
	mapping(address => bool) public gameAddresses;

	address public owner;

	modifier allowed() { require(gameAddresses[msg.sender]); _; }
	modifier owned() { require(msg.sender == owner); _; }

	function UserStats(
		address _owner
	) 
		public
	{
		owner = _owner;
	}

	function approve(
		address gameContract
	)
		external
		owned
	{
		gameAddresses[gameContract] = true;
	}

	function addPlayerWin(
		address user,
		uint32 entrySum,
		uint32 prize
	)
		external
		allowed
	{
		users[user].commandsCount++;
		users[user].totalLoseSum += entrySum;
		users[user].wins++;
		users[user].totalPrizeSum += prize;
	}

	function addPlayerLoose(
		address user,
		uint32 entrySum
	)
		external
		allowed
	{
		users[user].commandsCount++;
		users[user].totalLoseSum += entrySum;
	}

	function changeFeePercent(
		uint16 amount
	)
		external 
	{
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

	function allowance(
		address game
	) 
		external
		constant
		returns (bool) 
	{
		return gameAddresses[game];
	}

}