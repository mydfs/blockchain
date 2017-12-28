var Game = artifacts.require("Game");

contract('Game', function(accounts){

	it("game work correctly", function(){
		var game;

		var account_one = accounts[0];

		var team_one = [3, 4, 5];
		var team_two = [1, 2, 3];

		var sportsmanFlat = [1, 2, 2, 1, 2, 2, 2, 6, 1, 3, 2, 2, 3, 1, 3, 2, 4, 1, 1, 2, 3, 4, 1, 4, 1, 1, 2, 2, 5, 1, 4, 1, 1, 2, 3];
		var rulesFlat = [1, 1, 40, 1, 2, 40, 2, 1, 10, 2, 2, 80, 3, 1, 100, 3, 2, 10, 4, 1, 20, 4, 2, 80];

		return Game.deployed().then(function(instance){
			game = instance;
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is team creation");
			return game.serviceFee.call();
		}).then(function(serviceFee){
			return game.addParticipant(account_one, team_one);
		}).then(function(){
			return game.teamsCountOf.call(account_one);
		}).then(function(count){
			assert.equal(count, 1, "account_one has 1 team");
			return game.addParticipant(account_one, team_two);
		}).then(function(){
			return game.teamsCountOf.call(account_one);
		}).then(function(count){
			assert.equal(count, 2, "account_one has 2 teams");
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is still team creation");
			return game.startGame();
		}).then(function(){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 1, "game state is In Progress");
			return game.finishGame()
		}).then(function(){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 2, "game state is finished");
			return game.setGameRules(rulesFlat);
		}).then(function(){
			return game.setGameStats(sportsmanFlat);
		}).then(function(){
			return game.calculatePlayersScores();
		}).then(function(){
			return game.sortPlayers();
		}).then(function(){
			return game.calculateWinners();
		}).then(function(){
			return game.playerScoreBy.call(0);
		}).then(function(score){
			assert.equal(score.valueOf(), 650, "team [1,2,3] has 650 scores")
			return game.playerScoreBy.call(1);
		}).then(function(score){
			assert.equal(score.valueOf(), 410, "team [3,4,5] has 410 scores")
		}).then(function(score){
			return game.sendPrizes();
		});;
	});
});