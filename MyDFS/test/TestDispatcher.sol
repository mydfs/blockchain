pragma solidity ^0.4.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Dispatcher.sol";
import "../contracts/MyDFSToken.sol";
import "../contracts/Game.sol";

contract TestDispatcher{

	address deployerAddress;

	Dispatcher dispatcher;

	Game game;

	MyDFSToken token;

	// function beforeAll() {
	// 	deployerAddress = address(this);
	// }

	// function testDeployToken() external {
	// 	token = new MyDFSToken();
	// }

	// function testDeployDispatcher() external {
	// 	dispatcher = new Dispatcher(address(token));
	// }

	// function testDeposit() external {
	// 	token.increaseApproval(deployerAddress, 100000);

	// 	uint expected = 1000;

	// 	dispatcher.deposit(expected);
	// 	Assert.equal(dispatcher.balanceOf(deployerAddress), 1000, "balance after deposit is 1000");
	// }

	// function testAttachDispatcher() external {
	// 	Assert.notEqual(address(dispatcher), 0x0, "dispatcher created");
	// }

	// function testDispatcherAttaches() external {
	// //set here the first address from test network
	// 	Assert.equal(dispatcher.service(), deployerAddress, "service attached");
	// 	Assert.notEqual(dispatcher.gameToken(), 0x0, "gameToken attached");
	// 	Assert.notEqual(dispatcher.stats(), 0x0, "stats attached");
	// 	Assert.notEqual(dispatcher.broker(), 0x0, "broker attached");
	// }

	// function testCreateGame() external {
	// 	uint8[] memory smallWinnerRules = new uint8[](3);
	// 	smallWinnerRules[0] = 50;
	// 	smallWinnerRules[1] = 30;
	// 	smallWinnerRules[2] = 20;

	// 	uint8[] memory largeWinnerRules = new uint8[](4);
	// 	largeWinnerRules[0] = 40;
	// 	largeWinnerRules[1] = 30;
	// 	largeWinnerRules[2] = 20;
	// 	largeWinnerRules[3] = 10;

	// 	address gameAddress = dispatcher.createGame(5, 20, smallWinnerRules, largeWinnerRules);

	// 	game = Game(gameAddress);
	// 	Assert.notEqual(gameAddress, 0, "message");
	// }

	// function testGameStatus() external {
	// 	uint state = uint(game.gameState());
	// 	uint expected = 0;
	// 	Assert.equal(state, expected, "Game state is TeamCreation");
	// }

	// function testParticipate() external {
	// 	int32[] memory team = new int32[](3);
	// 	team[0] = 1;
	// 	team[1] = 2;
	// 	team[2] = 3;
	// 	dispatcher.addParticipant(deployerAddress, team, address(game));

	// 	team[0] = 3;
	// 	team[1] = 4;
	// 	team[2] = 5;
	// 	dispatcher.addParticipant(deployerAddress, team, address(game));
	// }

	// function testFinishGame(){
	// 	int32[] memory sportsmanFlatData = new int32[](35);

 //        sportsmanFlatData[0] = 1;
 //        sportsmanFlatData[1] = 2;
 //        sportsmanFlatData[2] = 2;
 //        sportsmanFlatData[3] = 1;
 //        sportsmanFlatData[4] = 2;
 //        sportsmanFlatData[5] = 2;
 //        sportsmanFlatData[6] = 2;
 //        sportsmanFlatData[7] = 6;
 //        sportsmanFlatData[8] = 1;
 //        sportsmanFlatData[9] = 3;
 //        sportsmanFlatData[10] = 2;
 //        sportsmanFlatData[11] = 2;
 //        sportsmanFlatData[12] = 3;
 //        sportsmanFlatData[13] = 1;
 //        sportsmanFlatData[14] = 3;
 //        sportsmanFlatData[15] = 2;
 //        sportsmanFlatData[16] = 4;
 //        sportsmanFlatData[17] = 1;
 //        sportsmanFlatData[18] = 1;
 //        sportsmanFlatData[19] = 2;
 //        sportsmanFlatData[20] = 3;
 //        sportsmanFlatData[21] = 4;
 //        sportsmanFlatData[22] = 1;
 //        sportsmanFlatData[23] = 4;
 //        sportsmanFlatData[24] = 1;
 //        sportsmanFlatData[25] = 1;
 //        sportsmanFlatData[26] = 2;
 //        sportsmanFlatData[27] = 2;
 //        sportsmanFlatData[28] = 5;
 //        sportsmanFlatData[29] = 1;
 //        sportsmanFlatData[30] = 4;
 //        sportsmanFlatData[31] = 1;
 //        sportsmanFlatData[32] = 1;
 //        sportsmanFlatData[33] = 2;
 //        sportsmanFlatData[34] = 3;

 //        int32[] memory rulesFlat = new int32[](24);

 //        rulesFlat[0] = 1;
 //        rulesFlat[1] = 1;
 //        rulesFlat[2] = 40;
 //        rulesFlat[3] = 1;
 //        rulesFlat[4] = 2;
 //        rulesFlat[5] = 40;
 //        rulesFlat[6] = 2;
 //        rulesFlat[7] = 1;
 //        rulesFlat[8] = 10;
 //        rulesFlat[9] = 2;
 //        rulesFlat[10] = 2;
 //        rulesFlat[11] = 80;
 //        rulesFlat[12] = 3;
 //        rulesFlat[13] = 1;
 //        rulesFlat[14] = 100;
 //        rulesFlat[15] = 3;
 //        rulesFlat[16] = 2;
 //        rulesFlat[17] = 10;
 //        rulesFlat[18] = 4;
 //        rulesFlat[19] = 1;
 //        rulesFlat[20] = 20;
 //        rulesFlat[21] = 4;
 //        rulesFlat[22] = 2;
 //        rulesFlat[23] = 80;

	// 	dispatcher.finishGame(address(game), sportsmanFlatData, rulesFlat);
	// }

	// function testStartGame() external {
	// 	dispatcher.startGame(address(game));
	// 	uint state = uint(game.gameState());
	// 	uint expected = 1;

	// 	Assert.equal(state, expected, "Game state is InProgress");
	// }

}