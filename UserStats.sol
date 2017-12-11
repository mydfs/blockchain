pragma solidity ^0.4.16;

contract Stats {

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

	modifier allowed() { if (gameAddresses[msg.sender]) _; }

	modifier owned() { if (msg.sender == owner) _; }

	function Stats() public{
		owner = msg.sender;
	}

	function approve(address gameContract) public owned {
		gameAddresses[gameContract] = true;
	}

	function incStat(address user, bool win, uint256 entrySum, uint256 prize) public allowed{
		users[user].gamesCount++;
		if (win){
			users[user].wins++;
		}
		users[user].totalPrizeSum += prize;
		users[user].totalLoseSum += entrySum;
	}

	function changeFeePercent(uint16 amount) public {
		users[msg.sender].feePercent = amount;
	}

	function getFeePercent(address user) public constant returns (uint16 fee){
		return users[user].feePercent;
	}

	function getUserGamesCount(address user) public constant returns (uint256 gamesCount){
		return users[user].gamesCount;
	}

	function getUserWins(address user) public constant returns (uint256 wins){
		return users[user].wins;
	}

	function getUserPrizeSum(address user) public constant returns (uint256 totalPrizeSum){
		return users[user].totalPrizeSum;
	}

	function getUserLoseSum(address user) public constant returns (uint256 totalLoseSum){
		return users[user].totalLoseSum;
	}

}