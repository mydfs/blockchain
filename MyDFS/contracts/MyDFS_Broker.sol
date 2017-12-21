pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

contract BrokerManager is Broker {

	struct Term{
		uint256 amount;
		uint16 userFee;
	}

	mapping (address => mapping (address => Term)) allowed;

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

	//call this method before hire
	//gameToken.approve(<broker address>, amount to invest);
	function hire(
		address user, 
		uint256 tokensAmount
	)
		external
	{
		allowed[msg.sender][user] = Term(tokensAmount, stats.getFeePercent(user));
	}

	function fire(address user) external {
		allowed[msg.sender][user].amount = 0;
	}

	function transferFrom(
		address beneficiary,
		address user, 
		address to, 
		uint256 value
	) 
		external
		returns (bool success)
	{
		if (allowance(beneficiary, user) >= value){
			allowed[beneficiary][user].amount -= value;
			return token.transferFrom(beneficiary, to, value);
		} else {
			revert();
		}
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