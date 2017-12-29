pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';
import './interface/ERC223ReceivingContract.sol';

contract Game is ERC223ReceivingContract{

	enum State { TeamCreation, InProgress, Finished, Canceled }

	struct Player {
		address user;
		address beneficiary;
	}

	State public gameState;

	uint32 public gameEntry;
	uint8 public serviceFee;

	mapping (uint32 => Player) players;
	mapping (address => uint8) teamsCount; 
	Player[] rawPlayers;

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
		uint8 _serviceFee
	) 
		public 
	{
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
		uint32 teamId
	)
		external
		beforeStart
		owned
	{
		require(teamsCount[user] < 4);
		players[teamId] = Player(user, address(0x0));
		rawPlayers.push(players[teamId]);
		ParticipantAdded(user);
		teamsCount[user]++;
	}

	function addSponsoredParticipant(
		address user,
		uint32 teamId,
		address beneficiary
	)
		external
		beforeStart
		owned
	{
		require(teamsCount[user] < 4);
		players[teamId] = Player(user, beneficiary);
		rawPlayers.push(players[teamId]);
		ParticipantAdded(user);
		teamsCount[user]++;
	}

	function startGame() external owned {
		if (rawPlayers.length > 0){
			gameState = State.InProgress;
		} else {
			gameState = State.Finished;
		}
	}

	function cancelGame() external owned {
		gameState = State.Canceled;
		for (uint32 i = 0; i < rawPlayers.length; i++){
			balanceManager.depositTo(rawPlayers[i].user, gameEntry);
		}
	}

	function finishGame(
	)
		external
		owned
		inProgress
	{
		gameState = State.Finished;
	}

	function sendPrizes(
		uint[] winners
	)
 		external
 		owned
 		finished
 	{
		for (uint32 i = 0; i < winners.length; i += 2) {
			uint32 teamId = uint32(winners[i]);
			uint totalPlayerPrize = winners[i + 1];
			uint playerPrize = 0;
			address player = players[teamId].user;
			address beneficiary = players[teamId].beneficiary;

			if (beneficiary > 0){
				playerPrize = calculateUserPrize(player, beneficiary, totalPlayerPrize);
				uint256 beneficiaryPrize = totalPlayerPrize - playerPrize;
				gameToken.transfer(beneficiary, beneficiaryPrize);
				PrizeFor(beneficiary, beneficiaryPrize);
			} else {
				playerPrize = totalPlayerPrize;
			}
			balanceManager.depositTo(player, playerPrize);
			PrizeFor(player, playerPrize);
			stats.incStat(player, totalPlayerPrize > 0, gameEntry, totalPlayerPrize);
		}
		//comment this if sendPrizes erase out of gas and send winners partically
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
	}

	//uncomment this is sendGamePrize erase out of gas
	// function getGameFee(
	// )
	// 	external
	// 	owned
	// 	finished
	// {
	// 	gameToken.transfer(service, gameToken.balanceOf(address(this)));
	// } 

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

	function calculateUserPrize(address user, address beneficiary, uint totalPlayerPrize) internal view returns (uint256){
		return broker.getUserFee(beneficiary, user) * totalPlayerPrize / 100;
	}

	function tokenFallback(address from, uint value) public {
	}

}

