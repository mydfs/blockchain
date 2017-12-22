pragma solidity ^0.4.16;

import './interface/Token.sol';
import './UserStats.sol';
import './BrokerManager.sol';
import './MyDFSGame.sol';

contract Dispatcher {

	address service;

	Token gameToken;
	UserStats stats;
	BrokerManager broker;

	modifier owned() { if (msg.sender == service) _; }

	function Dispatcher(
		address gameTokenAddress
	) public {
		service = msg.sender;
		stats = new UserStats();
		broker = new BrokerManager(address(stats), gameTokenAddress);
		gameToken = Token(gameTokenAddress);
	}

	function createGame(
		uint64 id,
		uint32 gameEntryValue,
		uint8 serviceFeeValue,
		uint8[] smallGameWinnersPercents,
		uint8[] largeGameWinnersPercents
	)
		external
		owned
		returns (address game)
	{
		game = new MyDFSGame(
			id, 
			gameEntryValue,
			address(gameToken),
			address(stats),
			address(broker),
			service,
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
		MyDFSGame(game).startGame();
	}

	function cancelGame(
		address game
	) 
		external
		owned 
	{
		MyDFSGame(game).cancelGame();
	}

	function finishGame(
		address game,
		int32[] sportsmenFlatData, 
		int32[] rulesFlat
	) 
		external
		owned
	{
		MyDFSGame(game).finishGame(sportsmenFlatData, rulesFlat);
	}

	function participate(
		int32[] team, 
		address game
	)
		external
	{
		MyDFSGame gameInstance = MyDFSGame(game);
		if (gameToken.transferFrom(msg.sender, game, gameInstance.gameEntry())){
			gameInstance.participate(msg.sender, team);
		} else {
			revert();
		} 
	}

	function participateBeneficiary(
		int32[] team, 
		address game,
		address beneficiary
	)
		external
	{
		MyDFSGame gameInstance = MyDFSGame(game);
		if (broker.allowance(beneficiary, msg.sender) >= gameInstance.gameEntry()){
			gameToken.transferFrom(beneficiary, game, gameInstance.gameEntry());
			gameInstance.participateBeneficiary(msg.sender, team, beneficiary);
		} else {
			revert();
		} 
	}

}