pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

contract BrokerManager is Broker {

	//cтруктура соглашения количество токенов + процент юзера
	struct Term{
		uint256 amount;
		uint16 userFee;
	}

	//набор соглашений между брокерами и юзерами 
	mapping (address => mapping (address => Term)) allowed;

	mapping (address => mapping (address => Term)) userBrokers;

	Token token;
	Stats stats;

	function BrokerManager (
		address tokenAddress,
		address statsAddress
	) 
		public
	{
		token = Token(tokenAddress);
		stats = Stats(statsAddress);
	}

	function hire(
		address user, 
		uint256 tokensAmount
	)
		external
	{
		require(allowed[msg.sender][user].amount == 0);
		allowed[msg.sender][user] = Term(tokensAmount, stats.getFeePercent(user));
		userBrokers[user][msg.sender] = allowed[msg.sender][user];
	}

	function fire(address user) external {
		allowed[msg.sender][user].amount = 0;
		allowed[user][msg.sender].amount = 0;
	}

	function getUserFee(
		address beneficiary, 
		address user
	)
		external
		constant
		returns (uint16)
	{
		return allowed[beneficiary][user].userFee;
	}

	function allowance(
		address beneficiary,
		address user
	) 
		public
		constant
		returns (uint256) 
	{
		return allowed[beneficiary][user].amount;
	}

}