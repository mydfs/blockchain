var Game = artifacts.require("Game");

contract('Game', function(accounts){

	it("game work correctly", function(){
		var game;

		var account_one = accounts[0];

		var team0 = [3, 3, 1, 4, 3, 1, 3];
		var team1 = [3, 1, 3, 3, 2, 1, 1];
		var team2 = [1, 4, 4, 3, 4, 2, 2];
		var team3 = [3, 1, 3, 1, 2, 4, 3];
		var team4 = [3, 4, 3, 3, 2, 4, 3];
		var team5 = [2, 3, 2, 2, 4, 1, 3];
		var team6 = [4, 1, 1, 2, 3, 3, 2];
		var team7 = [1, 4, 4, 1, 2, 3, 4];
		var team8 = [4, 4, 3, 4, 2, 4, 2];
		var team9 = [3, 2, 3, 1, 2, 2, 3];
		var team10 = [4, 4, 2, 4, 1, 1, 1];
		var team11 = [2, 2, 2, 4, 1, 4, 3];
		var team12 = [4, 4, 1, 1, 4, 4, 4];
		var team13 = [1, 2, 1, 4, 4, 3, 4];
		var team14 = [1, 3, 3, 3, 1, 2, 3];
		var team15 = [2, 3, 4, 2, 1, 4, 3];
		var team16 = [3, 3, 4, 3, 3, 1, 3];
		var team17 = [4, 2, 3, 3, 3, 1, 4];
		var team18 = [4, 2, 3, 1, 3, 1, 3];
		var team19 = [1, 1, 3, 1, 4, 4, 4];
		var team20 = [3, 1, 1, 2, 2, 2, 3];
		var team21 = [1, 3, 1, 3, 3, 1, 2];
		var team22 = [3, 4, 3, 2, 4, 2, 1];
		var team23 = [3, 3, 3, 2, 2, 1, 4];
		var team24 = [1, 3, 3, 3, 4, 1, 4];
		var team25 = [3, 2, 2, 2, 3, 3, 1];
		var team26 = [1, 2, 1, 4, 2, 3, 2];
		var team27 = [1, 2, 4, 1, 2, 1, 2];
		var team28 = [3, 3, 2, 4, 2, 1, 1];
		var team29 = [2, 3, 4, 3, 3, 2, 4];
		var team30 = [2, 4, 3, 3, 2, 1, 1];
		var team31 = [3, 2, 1, 3, 2, 1, 2];
		var team32 = [3, 2, 4, 1, 3, 2, 4];
		var team33 = [4, 3, 2, 2, 1, 3, 2];
		var team34 = [4, 1, 2, 1, 4, 3, 4];
		var team35 = [4, 3, 4, 2, 1, 3, 2];
		var team36 = [2, 3, 3, 4, 3, 4, 2];
		var team37 = [4, 3, 4, 2, 3, 4, 4];
		var team38 = [4, 3, 1, 1, 1, 3, 4];
		var team39 = [1, 4, 3, 1, 4, 3, 2];
		var team40 = [2, 3, 2, 3, 3, 2, 2];
		var team41 = [1, 3, 4, 4, 3, 1, 2];
		var team42 = [4, 3, 1, 1, 4, 3, 2];
		var team43 = [1, 3, 1, 1, 1, 4, 4];
		var team44 = [4, 3, 4, 1, 3, 2, 3];
		var team45 = [1, 4, 4, 1, 4, 1, 4];
		var team46 = [1, 2, 3, 2, 4, 4, 4];
		var team47 = [3, 2, 4, 4, 1, 2, 3];
		var team48 = [4, 4, 4, 1, 1, 1, 4];
		var team49 = [3, 2, 2, 2, 4, 4, 1];
		var team50 = [4, 2, 3, 4, 2, 4, 4];
		var team51 = [4, 1, 4, 4, 1, 1, 1];
		var team52 = [1, 1, 4, 3, 1, 3, 3];
		var team53 = [2, 4, 4, 1, 4, 3, 1];
		var team54 = [3, 3, 2, 4, 3, 1, 4];
		var team55 = [3, 2, 3, 4, 3, 4, 1];
		var team56 = [2, 4, 1, 3, 3, 4, 1];
		var team57 = [3, 1, 2, 3, 3, 1, 3];
		var team58 = [1, 3, 1, 4, 1, 1, 1];
		var team59 = [4, 1, 1, 2, 3, 1, 4];
		var team60 = [1, 2, 2, 3, 1, 4, 1];
		var team61 = [3, 3, 1, 3, 1, 2, 2];
		var team62 = [4, 1, 3, 4, 2, 4, 3];
		var team63 = [3, 2, 2, 4, 1, 2, 1];
		var team64 = [4, 2, 4, 2, 2, 3, 3];
		var team65 = [1, 3, 4, 1, 2, 4, 2];
		var team66 = [1, 2, 3, 1, 4, 2, 2];
		var team67 = [4, 3, 3, 4, 2, 4, 2];
		var team68 = [3, 1, 1, 3, 1, 1, 4];
		var team69 = [2, 4, 3, 4, 3, 3, 2];
		var team70 = [1, 4, 3, 3, 4, 3, 3];
		var team71 = [1, 4, 1, 3, 4, 2, 1];
		var team72 = [3, 3, 3, 1, 2, 3, 3];
		var team73 = [1, 1, 3, 3, 4, 1, 2];
		var team74 = [3, 4, 1, 1, 1, 4, 4];
		var team75 = [4, 4, 3, 1, 1, 3, 4];
		var team76 = [3, 1, 2, 4, 3, 2, 3];
		var team77 = [4, 3, 2, 1, 2, 3, 3];
		var team78 = [2, 2, 3, 2, 4, 4, 4];
		var team79 = [3, 2, 1, 2, 1, 3, 3];
		var team80 = [1, 3, 1, 2, 4, 2, 2];
		var team81 = [1, 2, 4, 4, 3, 3, 4];
		var team82 = [3, 1, 4, 4, 2, 4, 4];
		var team83 = [3, 4, 1, 3, 4, 4, 4];
		var team84 = [2, 1, 4, 2, 4, 3, 3];
		var team85 = [2, 1, 4, 2, 3, 3, 1];
		var team86 = [4, 4, 4, 1, 3, 4, 4];
		var team87 = [2, 4, 3, 4, 3, 1, 2];
		var team88 = [4, 4, 3, 1, 1, 3, 2];
		var team89 = [4, 1, 1, 4, 1, 1, 4];
		var team90 = [4, 1, 2, 1, 4, 1, 3];
		var team91 = [2, 1, 4, 1, 4, 2, 4];
		var team92 = [1, 1, 2, 2, 2, 1, 4];
		var team93 = [4, 3, 1, 4, 4, 4, 1];
		var team94 = [1, 4, 2, 2, 2, 3, 1];
		var team95 = [4, 1, 1, 1, 2, 4, 1];
		var team96 = [4, 2, 1, 4, 2, 4, 2];
		var team97 = [1, 2, 4, 1, 1, 1, 1];
		var team98 = [2, 3, 1, 1, 1, 2, 1];
		var team99 = [1, 1, 4, 1, 2, 1, 3];


		var sportsmanFlat = [1, 2, 2, 1, 2, 2, 2, 6, 1, 3, 2, 2, 3, 1, 3, 2, 4, 1, 1, 2, 3, 4, 1, 4, 1, 1, 2, 2, 5, 1, 4, 1, 1, 2, 3];
		var rulesFlat = [1, 1, 40, 1, 2, 40, 2, 1, 10, 2, 2, 80, 3, 1, 100, 3, 2, 10, 4, 1, 20, 4, 2, 80];

		return Game.deployed().then(function(instance){
			game = instance;
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is team creation");
			return game.serviceFee.call();
		}).then(function(serviceFee){
			return game.addParticipant(account_one, team0);
		}).then(function(){
			return game.addParticipant(account_one, team1);
		}).then(function(){
			return game.addParticipant(account_one, team2);
		}).then(function(){
			return game.addParticipant(account_one, team3);
		}).then(function(){
			return game.addParticipant(account_one, team4);
		}).then(function(){
			return game.addParticipant(account_one, team5);
		}).then(function(){
			return game.addParticipant(account_one, team6);
		}).then(function(){
			return game.addParticipant(account_one, team7);
		}).then(function(){
			return game.addParticipant(account_one, team8);
		}).then(function(){
			return game.addParticipant(account_one, team9);
		}).then(function(){
			return game.addParticipant(account_one, team10);
		}).then(function(){
			return game.addParticipant(account_one, team11);
		}).then(function(){
			return game.addParticipant(account_one, team12);
		}).then(function(){
			return game.addParticipant(account_one, team13);
		}).then(function(){
			return game.addParticipant(account_one, team14);
		}).then(function(){
			return game.addParticipant(account_one, team15);
		}).then(function(){
			return game.addParticipant(account_one, team16);
		}).then(function(){
			return game.addParticipant(account_one, team17);
		}).then(function(){
			return game.addParticipant(account_one, team18);
		}).then(function(){
			return game.addParticipant(account_one, team19);
		}).then(function(){
			return game.addParticipant(account_one, team20);
		}).then(function(){
			return game.addParticipant(account_one, team21);
		}).then(function(){
			return game.addParticipant(account_one, team22);
		}).then(function(){
			return game.addParticipant(account_one, team23);
		}).then(function(){
			return game.addParticipant(account_one, team24);
		}).then(function(){
			return game.addParticipant(account_one, team25);
		}).then(function(){
			return game.addParticipant(account_one, team26);
		}).then(function(){
			return game.addParticipant(account_one, team27);
		}).then(function(){
			return game.addParticipant(account_one, team28);
		}).then(function(){
			return game.addParticipant(account_one, team29);
		}).then(function(){
			return game.addParticipant(account_one, team30);
		}).then(function(){
			return game.addParticipant(account_one, team31);
		}).then(function(){
			return game.addParticipant(account_one, team32);
		}).then(function(){
			return game.addParticipant(account_one, team33);
		}).then(function(){
			return game.addParticipant(account_one, team34);
		}).then(function(){
			return game.addParticipant(account_one, team35);
		}).then(function(){
			return game.addParticipant(account_one, team36);
		}).then(function(){
			return game.addParticipant(account_one, team37);
		}).then(function(){
			return game.addParticipant(account_one, team38);
		}).then(function(){
			return game.addParticipant(account_one, team39);
		}).then(function(){
			return game.addParticipant(account_one, team40);
		}).then(function(){
			return game.addParticipant(account_one, team41);
		}).then(function(){
			return game.addParticipant(account_one, team42);
		}).then(function(){
			return game.addParticipant(account_one, team43);
		}).then(function(){
			return game.addParticipant(account_one, team44);
		}).then(function(){
			return game.addParticipant(account_one, team45);
		}).then(function(){
			return game.addParticipant(account_one, team46);
		}).then(function(){
			return game.addParticipant(account_one, team47);
		}).then(function(){
			return game.addParticipant(account_one, team48);
		}).then(function(){
			return game.addParticipant(account_one, team49);
		}).then(function(){
			return game.addParticipant(account_one, team50);
		}).then(function(){
			return game.addParticipant(account_one, team51);
		}).then(function(){
			return game.addParticipant(account_one, team52);
		}).then(function(){
			return game.addParticipant(account_one, team53);
		}).then(function(){
			return game.addParticipant(account_one, team54);
		}).then(function(){
			return game.addParticipant(account_one, team55);
		}).then(function(){
			return game.addParticipant(account_one, team56);
		}).then(function(){
			return game.addParticipant(account_one, team57);
		}).then(function(){
			return game.addParticipant(account_one, team58);
		}).then(function(){
			return game.addParticipant(account_one, team59);
		}).then(function(){
			return game.addParticipant(account_one, team60);
		}).then(function(){
			return game.addParticipant(account_one, team61);
		}).then(function(){
			return game.addParticipant(account_one, team62);
		}).then(function(){
			return game.addParticipant(account_one, team63);
		}).then(function(){
			return game.addParticipant(account_one, team64);
		}).then(function(){
			return game.addParticipant(account_one, team65);
		}).then(function(){
			return game.addParticipant(account_one, team66);
		}).then(function(){
			return game.addParticipant(account_one, team67);
		}).then(function(){
			return game.addParticipant(account_one, team68);
		}).then(function(){
			return game.addParticipant(account_one, team69);
		}).then(function(){
			return game.addParticipant(account_one, team70);
		}).then(function(){
			return game.addParticipant(account_one, team71);
		}).then(function(){
			return game.addParticipant(account_one, team72);
		}).then(function(){
			return game.addParticipant(account_one, team73);
		}).then(function(){
			return game.addParticipant(account_one, team74);
		}).then(function(){
			return game.addParticipant(account_one, team75);
		}).then(function(){
			return game.addParticipant(account_one, team76);
		}).then(function(){
			return game.addParticipant(account_one, team77);
		}).then(function(){
			return game.addParticipant(account_one, team78);
		}).then(function(){
			return game.addParticipant(account_one, team79);
		}).then(function(){
			return game.addParticipant(account_one, team80);
		}).then(function(){
			return game.addParticipant(account_one, team81);
		}).then(function(){
			return game.addParticipant(account_one, team82);
		}).then(function(){
			return game.addParticipant(account_one, team83);
		}).then(function(){
			return game.addParticipant(account_one, team84);
		}).then(function(){
			return game.addParticipant(account_one, team85);
		}).then(function(){
			return game.addParticipant(account_one, team86);
		}).then(function(){
			return game.addParticipant(account_one, team87);
		}).then(function(){
			return game.addParticipant(account_one, team88);
		}).then(function(){
			return game.addParticipant(account_one, team89);
		}).then(function(){
			return game.addParticipant(account_one, team90);
		}).then(function(){
			return game.addParticipant(account_one, team91);
		}).then(function(){
			return game.addParticipant(account_one, team92);
		}).then(function(){
			return game.addParticipant(account_one, team93);
		}).then(function(){
			return game.addParticipant(account_one, team94);
		}).then(function(){
			return game.addParticipant(account_one, team95);
		}).then(function(){
			return game.addParticipant(account_one, team96);
		}).then(function(){
			return game.addParticipant(account_one, team97);
		}).then(function(){
			return game.addParticipant(account_one, team98);
		}).then(function(){
			return game.addParticipant(account_one, team99);
		}).then(function(){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is still team creation");
			return game.startGame();
		}).then(function(){
			console.log("game started");
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 1, "game state is In Progress");
			return game.finishGame()
		}).then(function(){
			console.log("game finished");
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 2, "game state is finished");
			return game.setGameRules(rulesFlat);
		}).then(function(){
			console.log("rules compiled");
			return game.setGameStats(sportsmanFlat);
		}).then(function(){
			console.log("stats compiled");
			return game.calculatePlayersScores();
		}).then(function(){
			console.log("calculatePlayersScores");
			return game.sortPlayers();
		}).then(function(){
			console.log("sort players");
			return game.calculateWinners();
		}).then(function(){
			console.log("calculateWinners");
		});
	});
});