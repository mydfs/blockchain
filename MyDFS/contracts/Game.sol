pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './GameLogic.sol';

contract Game {

	enum State { TeamCreation, InProgress, Finished, Canceled }

	State public gameState;

	GameLogic.Data data;

	uint32 public gameEntry;
	uint8 public serviceFee;

	mapping (address => uint8) teamsCount; 

	address dispatcher;
	address service;
	Token gameToken;
	Stats stats;
	Broker broker;

	modifier owned() { require(msg.sender == dispatcher); _; }
	modifier beforeStart() { require(gameState == State.TeamCreation); _; }
	modifier inProgress() {  require(gameState == State.InProgress); _; }

	event ParticipantAdded(address user);
	event PrizeFor(address user, uint256 prize);

	//externals

	function Game(
		address gameTokenAddress,
		address statsAddress,
		address brokerAddress,
		address serviceAddress,
		uint32 _gameEntry,
		uint8 _serviceFee,
		uint8[] smallGameWinnersPercents,
		uint8[] largeGameWinnersPercents
	) 
		public 
	{
		data.smallGameRules = smallGameWinnersPercents;
		data.largeGameRules = largeGameWinnersPercents;
        
        dispatcher = msg.sender;
		gameState = State.TeamCreation;

		gameEntry = _gameEntry;
		serviceFee = _serviceFee;
		service = serviceAddress;
		gameToken = Token(gameTokenAddress);
		stats = Stats(statsAddress);
		broker = Broker(brokerAddress);
	}

	function addParticipant(
		address user,
		int32[] team
	)
		external
		beforeStart
		owned
	{
		require(teamsCount[user] <= 4);
		data.players.push(GameLogic.Player(user, address(0x0), team, 0, 0));
		ParticipantAdded(user);
		teamsCount[user]++;
	}

	function addSponsoredParticipant(
		address user,
		int32[] team,
		address beneficiary
	)
		external
		beforeStart
		owned
	{
		require(teamsCount[user] <= 4);
		data.players.push(GameLogic.Player(user, beneficiary, team, 0, 0));
		ParticipantAdded(user);
		teamsCount[user]++;
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
	    GameLogic.compileRules(data, rulesFlat);
		GameLogic.compileGameStats(data, sportsmenFlatData);
		GameLogic.calculatePlayersScores(data);
		GameLogic.sortPlayers(data);
		GameLogic.calculateWinners(data, totalPrize());
		GameLogic.updateUsersStats(stats, data.players, gameEntry);
		sendPrizes();

		gameState = State.Finished;
	}

	function teamsCountOf(
		address user
	) 
		external
		view
		returns (uint8)
	{
		return teamsCount[user];
	} 

	function totalPrize (
	) 
		public
		view
		returns (uint256)
	{
		return gameToken.balanceOf(address(this)) * (100 - serviceFee) / 100;
	} 

	function sendPrizes() internal {
		for (uint32 i = 0; i < data.players.length; i++) {
			address player = data.players[i].user;
			uint256 playerPrize = 0;
			address beneficiary = data.players[i].beneficiary;

			if (beneficiary > 0){
				playerPrize = calculateUserPrize(i);
				uint256 beneficiaryPrize = data.players[i].prize - playerPrize;
				gameToken.transfer(beneficiary, beneficiaryPrize);
				PrizeFor(beneficiary, beneficiaryPrize);
			} else {
				playerPrize = data.players[i].prize;
			}
			gameToken.transfer(player, playerPrize);
			PrizeFor(player, playerPrize);
		}
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
	}

	function calculateUserPrize(uint i) internal view returns (uint256){
		return broker.getUserFee(data.players[i].beneficiary, data.players[i].user) * data.players[i].prize / 100;
	}

}

