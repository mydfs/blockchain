pragma solidity ^0.4.16;

import './interface/Token.sol';
import './UserStats.sol';
import './BrokerManager.sol';
import './Game.sol';

contract Dispatcher {

	address public service;

	Token public gameToken;
	UserStats public stats;
	BrokerManager public broker;

	mapping (address => uint256) balances;

	modifier owned() { require(msg.sender == service); _; }

	function Dispatcher(
		address gameTokenAddress
	) public {
		service = msg.sender;
		stats = new UserStats();
		broker = new BrokerManager(gameTokenAddress, address(stats));
		gameToken = Token(gameTokenAddress);
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
		Game game = new Game(
			address(gameToken),
			address(stats),
			address(broker),
			service,
			gameEntryValue,
			serviceFeeValue,
			smallGameWinnersPercents,
			largeGameWinnersPercents);
		stats.approve(address(game));
		return address(game);
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
		address game,
		int32[] sportsmenFlatData, 
		int32[] rulesFlat
	) 
		external
		owned
	{
		Game(game).finishGame(sportsmenFlatData, rulesFlat);
	}

	function participate(
		address user,
		int32[] team, 
		address game
	)
		external
		owned
	{
		Game gameInstance = Game(game);
		require(balanceOf(user) >=  gameInstance.gameEntry() && gameToken.transfer(game, gameInstance.gameEntry()));
		gameInstance.addParticipant(user, team);
	}

	function participateBeneficiary(
		address user,
		int32[] team, 
		address game,
		address beneficiary
	)
		external
		owned
	{
		Game gameInstance = Game(game);
		require(broker.allowance(beneficiary, user) >= gameInstance.gameEntry());
		gameToken.transferFrom(beneficiary, game, gameInstance.gameEntry());
		gameInstance.addSponsoredParticipant(user, team, beneficiary);
	}

	function deposit(
		uint256 sum
	) 
		external 
	{
		if (gameToken.balanceOf(msg.sender) >= sum) {
			if (gameToken.transferFrom(msg.sender, address(this), sum)) {
				balances[msg.sender] += sum;
			}
		}
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

}