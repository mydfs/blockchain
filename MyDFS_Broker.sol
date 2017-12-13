pragma solidity ^0.4.16;

interface Token {
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function balanceOf(address owner) public constant returns (uint256 balance);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);
} 

contract Broker {

	mapping (address => mapping (address => uint256)) allowed;

	Token token;

	function Broker(address tokenAddress) public {
		token = Token(tokenAddress);
	}

	//call this method before hire
	//gameToken.approve(<broker address>, amount to invest);
	function hire(address user, uint256 tokensAmount) public{
		allowed[msg.sender][user] = tokensAmount;
	}

	function fire(address user) public{
		allowed[msg.sender][user] = 0;
	}

	function transferFrom(address beneficiary, address user, address to, uint256 value) public returns (bool success){
		if (allowed[beneficiary][user] >= value){
			allowed[beneficiary][user] -= value;
			return token.transferFrom(beneficiary, to, value);
		} else {
			revert();
		}
	}

	function allowance(address beneficiary, address user) public constant returns (uint256 remaining) {
		return allowed[beneficiary][user];
	}

}