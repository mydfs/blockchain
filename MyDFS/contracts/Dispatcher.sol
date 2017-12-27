pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

import './Game.sol';

contract Dispatcher {

	address public service;

	Token public gameToken;
	Stats public stats;
	Broker public broker;

	mapping (address => uint256) balances;

	modifier owned() { require(msg.sender == service); _; }

	function Dispatcher(
		address gameTokenAddress
	) public {
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
		uint32 gameEntryValue,
		uint8 serviceFeeValue,
		uint8[] smallGameWinnersPercents,
		uint8[] largeGameWinnersPercents
	)
		external
		owned
		returns (address)
	{
		address game = new Game(
			address(gameToken),
			address(stats),
			address(broker),
			service,
			gameEntryValue,
			serviceFeeValue,
			smallGameWinnersPercents,
			largeGameWinnersPercents);
		stats.approve(game);
		return game;
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

	function setGameRules(
		address game,
		int32[] rulesFlat
	)
		external
		owned
	{
		Game(game).setGameRules(rulesFlat);
	}

	function setGameStats(
		address game,
		int32[] sportsmenFlatData
	)
		external
		owned
	{
		Game(game).setGameStats(sportsmenFlatData);
	}

	function calculateGamePlayersScores(
		address game
	)
		external
		owned
	{
		Game(game).calculatePlayersScores();
	}
		
	function sortGamePlayers(
		address game
	)
		external
		owned
	{
		Game(game).sortPlayers();
	}	
	
	function calculateGameWinners(
		address game
	)
		external
		owned
	{
		Game(game).calculateWinners();
	}
	
	function updateGameUsersStats(
		address game
	)
		external
		owned
	{
		Game(game).updateUsersStats();
	}

	function sendGamePrizes(
		address game
	)
		external
		owned
	{
		Game(game).sendPrizes();
	}


	function addParticipant(
		address user,
		int32[] team, 
		address game
	)
		external
		owned
	{
		Game gameInstance = Game(game);
		require(balanceOf(user) >= gameInstance.gameEntry() && gameToken.transfer(game, gameInstance.gameEntry()));
		gameInstance.addParticipant(user, team);
	}

	function addSponsoredParticipant(
		address user,
		int32[] team, 
		address game,
		address beneficiary
	)
		external
		owned
	{
		Game gameInstance = Game(game);
		require(broker.allowance(beneficiary, user) >= gameInstance.gameEntry()
			&& gameToken.transferFrom(beneficiary, game, gameInstance.gameEntry()));
		gameInstance.addSponsoredParticipant(user, team, beneficiary);
	}

	function tokenFallback(address from, uint value, bytes data) public {
		deposit(from, value);
	}

	function deposit(
		uint sum
	) 
		external 
	{
		deposit(msg.sender, sum);
	}

	function withdraw(
		uint256 sum
	) 
		external
	{
		if (balances[msg.sender] >= sum) {
			if (gameToken.transfer(msg.sender, sum)) {
				balances[msg.sender] -= sum;
			}
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

	function deposit(address from, uint sum) internal {
		require(gameToken.balanceOf(from) >= sum); 
		if (gameToken.transferFrom(from, address(this), sum)) {
			balances[msg.sender] += sum;
		}	
	}

}