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

	//сделать map => user -> broker

	function BrokerManager (
		address tokenAddress,
		address statsAddress
	) 
		public
	{
		require(tokenAddress != address(0)
			&& statsAddress != address(0));
		token = Token(tokenAddress);
		stats = Stats(statsAddress);
	}

	//call this method before hire
	//gameToken.approve(<broker address>, amount to invest);
	function hire(
		address user, 
		uint256 tokensAmount
	)
		external
	{
		if (allowed[msg.sender][user].amount == 0){
			allowed[msg.sender][user] = Term(tokensAmount, stats.getFeePercent(user));
			userBrokers[user][msg.sender] = Term(tokensAmount, stats.getFeePercent(user));
		} else {
			revert();
		}
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
		returns (uint16 fee)
	{
		return allowed[beneficiary][user].userFee;
	}

	function allowance(
		address beneficiary,
		address user
	) 
		public
		constant
		returns (uint256 remaining) 
	{
		return allowed[beneficiary][user].amount;
	}

}