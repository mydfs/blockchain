pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './MyDFSGameLogic.sol';

contract MyDFSGame {

	enum State { TeamCreation, InProgress, Finished, Canceled }

	State public gameState;

	MyDFSGameLogic.Data data;

	uint64 gameId;
	uint32 public gameEntry;
	uint8 public serviceFee;

	address dispatcher;
	address service;
	Token gameToken;
	Stats stats;
	Broker broker;

	modifier owned() { if (msg.sender == dispatcher) _; }
	modifier beforeStart() { if (gameState == State.TeamCreation) _; }
	modifier inProgress() { if (gameState == State.InProgress) _; }

	event Participate(address user);
	event Winner(address user, uint256 prize);

	//externals

	function MyDFSGame(
		uint64 id,
		uint32 gameEntryValue,
		address gameTokenAddress,
		address statsAddress,
		address brokerAddress,
		address serviceAddress,
		uint8 serviceFeeValue,
		uint8[] smallGameWinnersPercents,
		uint8[] largeGameWinnersPercents
	) 
		public 
	{
		require(gameEntryValue > 0
			&& gameTokenAddress != address(0)
			&& statsAddress != address(0)
			&& brokerAddress != address(0)
			&& serviceAddress != address(0)
			&& smallGameWinnersPercents.length > 0
			&& largeGameWinnersPercents.length > 0);

		data.smallGameRules = smallGameWinnersPercents;
		data.largeGameRules = largeGameWinnersPercents;
        
        dispatcher = msg.sender;
		gameState = State.TeamCreation;

		gameId = id;
		gameEntry = gameEntryValue;
		serviceFee = serviceFeeValue;
		service = serviceAddress;
		gameToken = Token(gameTokenAddress);
		stats = Stats(statsAddress);
		broker = Broker(brokerAddress);
	}

	function participate(
		address user,
		int32[] team
	)
		external
		beforeStart
		owned
	{
		if (data.teamsCount[user] <= 4){
			data.players.push(MyDFSGameLogic.Player(user, address(0x0), team, 0, 0));
			Participate(user);
			data.teamsCount[user]++;
		} else {
			revert();
		}
	}

	function participateBeneficiary(
		address user,
		int32[] team,
		address beneficiary
	)
		external
		beforeStart
		owned
	{
		if (data.teamsCount[user] <= 4){
			data.players.push(MyDFSGameLogic.Player(user, beneficiary, team, 0, 0));
			Participate(user);
			data.teamsCount[user]++;
		} else {
			revert();
		}
	}

	function startGame() external owned {
		if (data.players.length > 0){
			gameState = State.InProgress;
		} else {
			gameState = State.Finished;
		}
	}

	function cancelGame() external owned {
		gameState = State.Canceled;
		for (uint32 i = 0; i < data.players.length; i++){
			gameToken.transfer(data.players[i].user, gameEntry);
		}
	}

	function finishGame(
		int32[] sportsmenFlatData, 
		int32[] rulesFlat
	)
		external
		owned
		inProgress
	{
	    MyDFSGameLogic.compileRules(data, rulesFlat);
		MyDFSGameLogic.compileGameStats(data, sportsmenFlatData);
		MyDFSGameLogic.calculatePlayersScores(data);
		MyDFSGameLogic.sortPlayers(data);
		MyDFSGameLogic.calculateWinners(data, totalPrize());
		MyDFSGameLogic.updateUsersStats(stats, data.players, gameEntry);
		sendPrizes();

		gameState = State.Finished;
	}

	function sendPrizes() internal {
		for (uint32 i = 0; i < data.players.length; i++) {
			if (data.players[i].beneficiary > 0){
				uint256 userPrize = broker.getUserFee(data.players[i].beneficiary, 
					data.players[i].user) * data.players[i].prize / 100;
				uint256 beneficiaryPrize = data.players[i].prize - userPrize;
				if (userPrize > 0){
					gameToken.transfer(data.players[i].user, userPrize);
				}
				Winner(data.players[i].user, userPrize);
				if (beneficiaryPrize > 0){
					gameToken.transfer(data.players[i].beneficiary, beneficiaryPrize);
				}
				Winner(data.players[i].beneficiary, beneficiaryPrize);
			} else {
				if (data.players[i].prize > 0){
					gameToken.transfer(data.players[i].user, data.players[i].prize);
				}
				Winner(data.players[i].user, data.players[i].prize);
			}
		}
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
	}

	//public

	function totalPrize (
	) 
		public
		constant
		returns (uint256 prize)
	{
		return gameToken.balanceOf(address(this)) * (100 - serviceFee) / 100;
	} 

}

