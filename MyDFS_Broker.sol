pragma solidity ^0.4.16;

interface Token {
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function balanceOf(address owner) public constant returns (uint256 balance);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);
} 

interface Stats {
	function getFeePercent(address user) public constant returns (uint16 fee);
}

contract Broker {

	struct Term{
		uint256 amount;
		uint16 userFee;
	}

	mapping (address => mapping (address => Term)) allowed;

	Token token;
	Stats stats;

	function Broker(
		address tokenAddress,
		address statsAddress
		) public {
		token = Token(tokenAddress);
		stats = Stats(statsAddress);
	}

	//call this method before hire
	//gameToken.approve(<broker address>, amount to invest);
	function hire(address user, uint256 tokensAmount) public{
		allowed[msg.sender][user] = Term(tokensAmount, stats.getFeePercent(user));
	}

	function fire(address user) public{
		allowed[msg.sender][user].amount = 0;
	}

	function transferFrom(address beneficiary, address user, address to, uint256 value) public returns (bool success){
		if (allowed[beneficiary][user].amount >= value){
			allowed[beneficiary][user].amount -= value;
			return token.transferFrom(beneficiary, to, value);
		} else {
			revert();
		}
	}

	function getUserFee(address beneficiary, address user) public constant returns (uint16 fee) {
		return allowed[beneficiary][user].userFee;
	}

	function allowance(address beneficiary, address user) public constant returns (uint256 remaining) {
		return allowed[beneficiary][user].amount;
	}

}