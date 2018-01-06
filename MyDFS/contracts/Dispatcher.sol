pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';
import './interface/ERC223ReceivingContract.sol';
import './GameLogic.sol';
import './Game.sol';

contract Dispatcher is BalanceManager, ERC223ReceivingContract {

	address public service;

	Token public gameToken;
	Stats public stats;
	Broker public broker;

	mapping (address => uint32) balances;
	mapping (uint => address) public games;

	modifier owned() { require(msg.sender == service); _; }
	event GameCreated(address game);

	function Dispatcher(
		address gameTokenAddress
	) public {
		require(gameTokenAddress > 0);
		service = msg.sender;
		gameToken = Token(gameTokenAddress);
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
			address(this));
		stats.approve(address(game));
		GameCreated(address(game));
		games[id] = address(game);
	}

	function startGame(
		address game
	)
		external
		owned
	{
		Game(game).startGame();
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
		address game
	) 
		external
		owned
	{
		Game(game).finishGame();
	}

	function addParticipantsHash(
		string hash,
		address game
	)
		external
		owned
	{
		Game(game).addParticipantsHash(hash);
	}

	function tokenFallback(address from, uint value) public {
		balances[from] += value;
	}

	function deposit(
		uint sum
	) 
		external 
	{
		require(gameToken.balanceOf(msg.sender) >= sum); 
		if (gameToken.transferFrom(msg.sender, address(this), sum)) {
			balances[msg.sender] += sum;
		}
	}

	function depositTo(
		address to,
		uint sum
	) 
		external 
	{
		require(gameToken.balanceOf(msg.sender) >= sum); 
		if (gameToken.transferFrom(msg.sender, address(this), sum)) {
			balances[to] += sum;
		}	
	}

	function withdraw(
		uint256 sum
	)
		external
	{
		require(balances[msg.sender] >= sum);
		if (gameToken.transfer(msg.sender, sum)) {
			balances[msg.sender] -= sum;
		}
	}

	function balanceOf(
		address user
	)
		public
		constant
		returns (uint256)
	{
		return balances[user];
	}
}