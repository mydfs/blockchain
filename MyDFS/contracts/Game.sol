pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';
import './interface/ERC223ReceivingContract.sol';
import './GameLogic.sol';

contract Game is ERC223ReceivingContract{

	GameLogic.Data data;

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
	BalanceManager balanceManager;

	modifier owned() { require(msg.sender == dispatcher); _; }
	modifier beforeStart() { require(gameState == State.TeamCreation); _; }
	modifier inProgress() {  require(gameState == State.InProgress); _; }
	modifier finished() {  require(gameState == State.Finished); _; }

	event ParticipantAdded(address user);
	event PrizeFor(address user, uint256 prize);

	//externals

	function Game(
		address gameTokenAddress,
		address statsAddress,
		address brokerAddress,
		address serviceAddress,
		address balanceAddress,
		uint32 _gameEntry,
		uint8 _serviceFee,
		uint8[] smallGameRules,
		uint8[] largeGameRules
	) 
		public 
	{
		data.smallGameRules = smallGameRules;
		data.largeGameRules = largeGameRules;
        
        dispatcher = msg.sender;
		gameState = State.TeamCreation;

		gameEntry = _gameEntry;
		serviceFee = _serviceFee;
		service = serviceAddress;
		gameToken = Token(gameTokenAddress);
		stats = Stats(statsAddress);
		broker = Broker(brokerAddress);
		balanceManager = BalanceManager(balanceAddress);
		gameToken.increaseApproval(dispatcher, 2**255);
	}

	function addParticipant(
		address user,
		int32[] team
	)
		external
		beforeStart
		owned
	{
		// require(teamsCount[user] < 4);
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
		// require(teamsCount[user] < 4);
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

	//call order
	// finishGame
	// setGameRules
	// setGameStats
	// calculatePlayersScores
	// sortPlayers
	// calculateWinners
	// updateUsersStats
	// sendPrizes

	function finishGame(
	)
		external
		owned
		inProgress
	{
		gameState = State.Finished;
	}

	function setGameRules(
		int32[] rulesFlat
	)
		external
		owned
		finished
	{
		GameLogic.compileRules(data, rulesFlat);
	}

	function setGameStats(
		int32[] sportsmenFlatData
	)
		external
		owned
		finished
	{
		GameLogic.compileGameStats(data, sportsmenFlatData);
	}

	function calculatePlayersScores(
	)
		external
		owned
		finished
	{
		GameLogic.calculatePlayersScores(data);
	}
		
	function sortPlayers(
	)
		external
		owned
		finished
	{
		GameLogic.sortPlayers(data);
	}	
	
	function calculateWinners(
	)
		external
		owned
		finished
	{
		GameLogic.calculateWinners(data, totalPrize());
	}
	
	function updateUsersStats(
	)
		external
		owned
		finished
	{
		GameLogic.updateUsersStats(stats, data.players, gameEntry);
	}

	function sendPrizes() external owned finished {
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
			balanceManager.depositTo(player, playerPrize);
			PrizeFor(player, playerPrize);
		}
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
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

	function playerScoreBy(
		uint index
	)
		external
		view
		finished
		returns (int32)
	{
		return data.players[index].score;
	}

	function playerPrizeBy(
		uint index
	)
		external
		view
		finished
		returns (uint32)
	{
		return data.players[index].prize;
	}

	function totalPrize (
	) 
		public
		view
		returns (uint256)
	{
		return gameToken.balanceOf(address(this)) * (100 - serviceFee) / 100;
	} 

	function calculateUserPrize(uint i) internal view returns (uint256){
		return broker.getUserFee(data.players[i].beneficiary, data.players[i].user) * data.players[i].prize / 100;
	}

	function tokenFallback(address from, uint value) public {
	}

}

