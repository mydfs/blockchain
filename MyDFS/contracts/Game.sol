pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

contract Game {

	////

	struct Player {
		address user;
		address beneficiary;
		int32[] team;
		int32 score;
		uint32 prize;
	}

	Player[] players;
	uint8[] activeRule;
	mapping(int32 => int32) scores;
	mapping(int32 => mapping (int32 => int32)) rules;
	
	uint8[] smallGameRules;
	uint8[] largeGameRules;

	Player tmpPlayer;

	////

	enum State { TeamCreation, InProgress, Finished, Canceled }

	State public gameState;

	uint32 public gameEntry;
	uint8 public serviceFee;

	mapping (address => uint8) teamsCount; 

	address public dispatcher;
	address public service;
	Token public gameToken;
	Stats public stats;
	Broker public broker;

	address gameLibrary;

	modifier owned() { require(msg.sender == dispatcher); _; }
	modifier beforeStart() { require(gameState == State.TeamCreation); _; }
	modifier inProgress() {  require(gameState == State.InProgress); _; }

	event ParticipantAdded(address user);
	event PrizeFor(address user, uint256 prize);

	//externals

	function Game(
		address _gameLibrary,
		address gameTokenAddress,
		address statsAddress,
		address brokerAddress,
		address serviceAddress,
		uint32 _gameEntry,
		uint8 _serviceFee,
		uint8[] _smallGameRules,
		uint8[] _largeGameRules
	) 
		public 
	{
		smallGameRules = _smallGameRules;
		largeGameRules = _largeGameRules;
        
        dispatcher = msg.sender;
		gameState = State.TeamCreation;

		gameEntry = _gameEntry;
		gameLibrary = _gameLibrary;
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
		players.push(Player(user, address(0x0), team, 0, 0));
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
		players.push(Player(user, beneficiary, team, 0, 0));
		ParticipantAdded(user);
		teamsCount[user]++;
	}

	function startGame() external owned {
		if (players.length > 0){
			gameState = State.InProgress;
		} else {
			gameState = State.Finished;
		}
	}

	function cancelGame() external owned {
		gameState = State.Canceled;
		for (uint32 i = 0; i < players.length; i++){
			gameToken.transfer(players[i].user, gameEntry);
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
		gameLibrary.delegatecall(bytes4(sha3("compileRules(int32[])")), rulesFlat);
		gameLibrary.delegatecall(bytes4(sha3("compileGameStats(int32[])")), sportsmenFlatData);
		gameLibrary.delegatecall(bytes4(sha3("calculatePlayersScores()")));
		gameLibrary.delegatecall(bytes4(sha3("calculatePlayersScores()")));
		gameLibrary.delegatecall(bytes4(sha3("calculateWinners(uint256)")), totalPrize());
		gameLibrary.delegatecall(bytes4(sha3("updateUsersStats()")));

	    // GameLogic.compileRules(rulesFlat);
		// GameLogic.compileGameStats(sportsmenFlatData);
		// GameLogic.calculatePlayersScores();
		// GameLogic.sortPlayers();
		// GameLogic.calculateWinners(totalPrize());
		// GameLogic.updateUsersStats(stats, players, gameEntry);
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
		for (uint32 i = 0; i < players.length; i++) {
			address player = players[i].user;
			uint256 playerPrize = 0;
			address beneficiary = players[i].beneficiary;

			if (beneficiary > 0){
				playerPrize = calculateUserPrize(i);
				uint256 beneficiaryPrize = players[i].prize - playerPrize;
				gameToken.transfer(beneficiary, beneficiaryPrize);
				PrizeFor(beneficiary, beneficiaryPrize);
			} else {
				playerPrize = players[i].prize;
			}
			gameToken.transfer(player, playerPrize);
			PrizeFor(player, playerPrize);
		}
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
	}

	function calculateUserPrize(uint i) internal view returns (uint256){
		return broker.getUserFee(players[i].beneficiary, players[i].user) * players[i].prize / 100;
	}

}

