pragma solidity ^0.4.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Dispatcher.sol";
import "../contracts/MyDFSToken.sol";
import "../contracts/MyDFSGame.sol";

contract TestDispatcher{

	address deployerAddress;

	Dispatcher dispatcher;

	MyDFSGame game;

	MyDFSToken token;

	function beforeAll() {
		deployerAddress = address(this);
	}

	function testDeployToken() {
		token = new MyDFSToken();
	}

	function testDeployDispatcher() {
		dispatcher = new Dispatcher(address(token));
	}

	function testDeposit() external {
		token.increaseApproval(deployerAddress, 100000);

		uint expected = 1000;

		dispatcher.deposit(expected);
		Assert.equal(dispatcher.balanceOf(deployerAddress), 1000, "balance after deposit is 1000");
	}

	function testAttachDispatcher() external {
		Assert.notEqual(address(dispatcher), 0x0, "dispatcher created");
	}

	function testDispatcherAttaches() external {
	//set here the first address from test network
		Assert.equal(dispatcher.service(), deployerAddress, "service attached");
		Assert.notEqual(dispatcher.gameToken(), 0x0, "gameToken attached");
		Assert.notEqual(dispatcher.stats(), 0x0, "stats attached");
		Assert.notEqual(dispatcher.broker(), 0x0, "broker attached");
	}

	function testCreateGame() external {
		uint8[] memory smallWinnerRules = new uint8[](3);
		smallWinnerRules[0] = 50;
		smallWinnerRules[1] = 30;
		smallWinnerRules[2] = 20;

		uint8[] memory largeWinnerRules = new uint8[](4);
		largeWinnerRules[0] = 40;
		largeWinnerRules[1] = 30;
		largeWinnerRules[2] = 20;
		largeWinnerRules[3] = 10;

		address gameAddress = dispatcher.createGame(1, 5, 20, smallWinnerRules, largeWinnerRules);

		game = MyDFSGame(gameAddress);
		Assert.notEqual(gameAddress, 0, "message");
	}

	function testGameStatus() external {
		uint state = uint(game.gameState());
		uint expected = 0;
		Assert.equal(state, expected, "Game state is TeamCreation");
	}

	function testParticipate() external {
		int32[] memory team = new int32[](3);
		team[0] = 1;
		team[1] = 2;
		team[2] = 3;
		dispatcher.participate(0x627306090abab3a6e1400e9345bc60c78a8bef57, team, address(game));
	}

	function testStartGame() external {
		dispatcher.startGame(address(game));
		uint state = uint(game.gameState());
		uint expected = 1;

		Assert.equal(state, expected, "Game state is InProgress");
	}

}