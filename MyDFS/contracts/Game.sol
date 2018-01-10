pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';
import './interface/BalanceManager.sol';
import './interface/ERC223ReceivingContract.sol';

contract Game is ERC223ReceivingContract {

	enum State { TeamCreation, InProgress, Finished, Canceled }
	
	struct Winner {
		uint32 user;
		uint32 beneficiary;
		uint32 prize;
	}

	State public gameState;

	uint32 public gameEntry;
	uint8 public serviceFee;

	address public dispatcher;
	address public service;
	Token public gameToken;
	Stats public stats;
	Broker public broker;
	BalanceManager balanceManager;

	string public participantsHash;
	mapping (uint32 => uint8) public participants;
	string public eventsHash;

	Winner [] public winners;

	modifier owned() { require(msg.sender == dispatcher); _; }
	modifier beforeStart() { require(gameState == State.TeamCreation); _; }
	modifier inProgress() {  require(gameState == State.InProgress); _; }
	modifier finished() {  require(gameState == State.Finished); _; }

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

	function setParticipantsHash(
		string hash
	)
		external
		beforeStart
		owned
	{
		participantsHash = hash;
	}

	function addParticipant(
		uint32 user
	)
		external
		beforeStart
		owned
	{
        participants[user]++;
	}

	function setEventsHash(
		string hash
	)
		external
		finished
		owned
	{
		eventsHash = hash;
	}

	function startGame() external owned {
		gameState = State.InProgress;
	}

	function cancelGame() external owned {
		gameState = State.Canceled;
	}

	function finishGame(
	)
		external
		owned
		inProgress
	{
		gameState = State.Finished;
	}

	function addWinner(
		address user,
		address beneficiary,
		uint32 prize
	)
		external 
		owned 
		finished 
	{
		require(prize > 0); 

		/* winners.push(Winner(user, beneficiary, prize));
		if (beneficiary > 0){
			playerPrize = calculateUserPrize(i);
			uint256 beneficiaryPrize = prize - playerPrize;
			gameToken.transfer(beneficiary, beneficiaryPrize);
			PrizeFor(beneficiary, beneficiaryPrize);
		} else {
			playerPrize = prize;
		}
		balanceManager.depositTo(player, playerPrize);
		PrizeFor(player, playerPrize); */
	}

	function trasferFee () 
		external
		owned
		finished
	{
		gameToken.transfer(service, gameToken.balanceOf(address(this)));
	}
	

	function totalPrize (
	) 
		public
		view
		returns (uint256)
	{
		return gameToken.balanceOf(address(this)) * (100 - serviceFee) / 100;
	} 

	function tokenFallback(address from, uint value) public {
	}

	function calculateUserPrize(
		address user,
		address beneficiary,
		uint32 prize
	) 
		internal 
		view 
		returns (uint256)
	{
		return broker.getUserFee(beneficiary, user) * prize / 100;
	}
}

