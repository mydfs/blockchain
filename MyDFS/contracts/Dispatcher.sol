pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';
import './interface/ERC223ReceivingContract.sol';
import './Game.sol';

contract Dispatcher is BalanceManager, ERC223ReceivingContract {

	address public service;

	Token public gameToken;
	Stats public stats;
	Broker public broker;

	mapping (address => uint32) users;
	mapping (uint32 => uint32) public balances;
	mapping (uint => address) public games;

	uint32 max_id = 0;

	modifier owned() { require(msg.sender == service); _; }
	
	event GameCreated(address game);

	function Dispatcher(
		address gameTokenAddress
	) public {
		require(gameTokenAddress > 0);
		service = msg.sender;
		gameToken = Token(gameTokenAddress);
	}

	function registerUser(
		address user,
		uint32 id
	) 
		external
		owned
	{
		users[user] = id;
	}

	function setUserStats(
		address statsAddress
	)
		external
		owned
	{
		stats = Stats(statsAddress);
	}

	function setBroker(
		address brokerAddress
	) 
		external
		owned
	{
		broker = Broker(brokerAddress);
	}

	function createGame(
		uint32 id,
		uint32 gameEntryValue,
		uint8 serviceFeeValue
	)
		external
		owned
		returns (address)
	{
		require(id != 0x0);
		Game game = new Game(
			address(gameToken),
			address(stats),
			address(broker),
			service,
			address(this),
			gameEntryValue,
			serviceFeeValue);
		stats.approve(address(game));
		GameCreated(address(game));
		games[id] = address(game);
	}

	function addParticipants(
		uint32[] users
	)
		external
		owned
	{
		Game gameInstance = Game(game);
 		uint gameEntry = gameInstance.gameEntry();

		for (uint256 i = 0; i < users.length; i++) {
			require(balanceOf(user) >= gameEntry && gameToken.transfer(game, gameEntry));
 			balances[user] -= gameEntry;
            gameInstance.addParticipant(users[i]);
        }
	}

	function startGame(
		address game,
		string hash
	)
		external
		owned
	{
		Game(game).startGame();
		Game(game).setParticipantsHash(hash);
	}

	function cancelGame(
		address game
	) 
		external
		owned 
	{
		Game(game).cancelGame();
	}

	function finishGame(
		address game,
		string hash
	)
		external
		owned
	{
		Game(game).finishGame();
		Game(game).setEventsHash(hash);
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

	function deposit(
		uint32 sum
	) 
		external 
	{
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

	function withdraw(
		uint32 sum
	)
		external
	{
		require(balances[msg.sender] >= sum);
		if (gameToken.transfer(msg.sender, sum)) {
			uint32 userId = users[msg.sender];
			balances[userId] -= sum;
		}
	}

	function balanceOf(
		uint32 userId
	)
		public
		constant
		returns (uint32)
	{
		return balances[userId];
	}
}