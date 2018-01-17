pragma solidity ^0.4.18;

import './Ownable.sol';
import './MyDFSToken.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';

contract Dispatcher is BalanceManager, Ownable {

	MyDFSToken public gameToken;
	Stats public stats;
	Broker public broker;

	mapping (address => uint32) users;
	mapping (uint32 => uint32) public balances;
	mapping (uint => address) public games;

	uint32 max_id = 0;

	event GameCreated(address game);

	function Dispatcher(address gameTokenAddress) public {
		require(gameTokenAddress > 0);
		gameToken = MyDFSToken(gameTokenAddress);
	}

	function registerUser(
		address user,
		uint32 id
	) 
		external
		onlyOwner
	{
		users[user] = id;
	}

	function setUserStats(address statsAddress)
		external
		onlyOwner
	{
		stats = Stats(statsAddress);
	}

	function setBroker(address brokerAddress) 
		external
		onlyOwner
	{
		broker = Broker(brokerAddress);
	}

	function createGame(
		uint32 id,
		uint32 gameEntryValue,
		uint8 serviceFeeValue
	)
		external
		onlyOwner
		returns (address)
	{
		require(id != 0x0);
		
	}

	function addParticipants(
		uint32[] users,
		address game
	)
		external
		onlyOwner
	{
		
	}

	function startGame(
		address game,
		string hash
	)
		external
		onlyOwner
	{
		
	}

	function cancelGame(address game) 
		external
		onlyOwner 
	{
		
	}

	function finishGame(
		address game,
		string hash
	)
		external
		onlyOwner
	{
		
	}

	function tokenFallback(
		address from, 
		uint value
	) 
		public 
	{
		uint32 userId = users[from];
		require(userId > 0);
		balances[userId] += uint32(value);
	}

	function deposit(uint32 sum) external {
		require(gameToken.balanceOf(msg.sender) >= sum); 
		if (gameToken.transferFrom(msg.sender, address(this), sum)) {
			uint32 userId = users[msg.sender];
			balances[userId] += sum;
		}
	}

	function depositTo(
		address to,
		uint32 sum
	) 
		external 
	{
		require(gameToken.balanceOf(msg.sender) >= sum);
		if (gameToken.transferFrom(msg.sender, address(this), sum)) {
			uint32 userId = users[to];
			balances[userId] += sum;
		}	
	}

	function withdraw(uint32 sum) external {
		uint32 userId = users[msg.sender];
		require(balances[userId] >= sum);
		if (gameToken.transfer(msg.sender, sum)) {
			balances[userId] -= sum;
		}
	}

	function balanceOf(uint32 userId)
		public
		constant
		returns (uint32)
	{
		return balances[userId];
	}
}