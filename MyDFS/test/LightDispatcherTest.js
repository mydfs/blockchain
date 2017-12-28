var Dispatcher = artifacts.require("Dispatcher.sol");
var MyDFSToken = artifacts.require("MyDFSToken");
var Stats = artifacts.require("UserStats");
var Broker = artifacts.require("BrokerManager");
var Game = artifacts.require("Game");

var dispatcher;

contract('Dispatcher', function(accounts){
	it("stats and broker manager attaching correctly", function(){

		return Dispatcher.deployed().
			then(function(instance){
				dispatcher = instance;
				return Stats.deployed()
					.then(function(instance){
						return dispatcher.setUserStats(instance.address);
			}).then(function(){
				return Broker.deployed()
					.then(function(instance){
						return dispatcher.setBroker(instance.address);
				})
			}).then(function(){
				return dispatcher.stats.call();
			}).then(function(result){
				assert.notEqual(result, 0, "stats address not 0");
				return dispatcher.broker.call();
			}).then(function(result){
				assert.notEqual(result, 0, "broker address not 0");
			});
		});
	});

	it("deposit work correctly", function(){
		var token;

		var account_one = accounts[0];

		var one_token_balance_before;
		var one_token_balance_after;

		var one_dispatcher_balance_before;
		var one_dispatcher_balance_after;

		var depositAmount = 1000;

		return MyDFSToken.deployed().then(function(instance){
			token = instance;
			return token.increaseApproval(dispatcher.address, 100000, {from: account_one});
		}).then(function(){
			return token.balanceOf.call(account_one);
		}).then(function(balance){
			one_token_balance_before = balance.toNumber();
			return dispatcher.balanceOf.call(account_one);
		}).then(function(balance){
			one_dispatcher_balance_before = balance.toNumber();
			return dispatcher.deposit(depositAmount, {from: account_one});
		}).then(function(){
			return dispatcher.balanceOf.call(account_one);
		}).then(function(balance){
			one_dispatcher_balance_after = balance.toNumber();
			assert.equal(one_dispatcher_balance_after, one_dispatcher_balance_before + depositAmount, "deposit should increase to <depositAmount>");
			return token.balanceOf.call(account_one);
		}).then(function(balance){	
			one_token_balance_after = balance.toNumber();
			assert.equal(one_token_balance_before, one_token_balance_after + depositAmount, "balance should decrease to <depositAmount>");
		});
	});

	it("game work correctly", function(){
		var game;
		var stats;

		var account_one = accounts[0];

		var gameId = 1;
		var entry_value = 5;
		var service_fee_percent = 20;
		var small_game_prizes_percent = [50, 30, 20];
		var large_game_prizes_percent = [40, 30, 20, 10];

		var team_one = [1, 2, 3];
		var team_two = [3, 4, 5];

		var sportsmanFlat = [1, 2, 2, 1, 2, 2, 2, 6, 1, 3, 2, 2, 3, 1, 3, 2, 4, 1, 1, 2, 3, 4, 1, 4, 1, 1, 2, 2, 5, 1, 4, 1, 1, 2, 3];
		var rulesFlat = [1, 1, 40, 1, 2, 40, 2, 1, 10, 2, 2, 80, 3, 1, 100, 3, 2, 10, 4, 1, 20, 4, 2, 80];

		return Dispatcher.deployed().then(function(instance){
			dispatcher = instance;
			return dispatcher.service.call();
		}).then(function(result){
			return dispatcher.createGame(gameId, entry_value, service_fee_percent, small_game_prizes_percent, large_game_prizes_percent, {from : account_one});;
		}).then(function(){
			return dispatcher.games.call(gameId);
		}).then(function(gameAddress){
			assert.notEqual(gameAddress, 0, "game address is not 0");
			game = Game.at(gameAddress);
			return game.dispatcher.call();
		}).then(function(result){
			return game.service.call();
		}).then(function(result){
			return game.gameToken.call();
		}).then(function(result){
			return game.stats.call();
		}).then(function(result){
			return game.broker.call();
		}).then(function(result){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is team creation");
			return game.serviceFee.call();
		}).then(function(serviceFee){
			return dispatcher.addParticipant(account_one, team_one, game.address);
		}).then(function(){
			return game.teamsCountOf.call(account_one);
		}).then(function(count){
			assert.equal(count, 1, "account_one has 1 team");
			return dispatcher.addParticipant(account_one, team_two, game.address);
		}).then(function(){
			return game.teamsCountOf.call(account_one);
		}).then(function(count){
			assert.equal(count, 2, "account_one has 2 teams");
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is still team creation");
			return dispatcher.startGame(game.address);
		}).then(function(){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 1, "game state is In Progress");
			return dispatcher.finishGame(game.address)
		}).then(function(){
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 2, "game state is finished");
			return dispatcher.setGameRules(game.address, rulesFlat);
		}).then(function(){
			return dispatcher.setGameStats(game.address, sportsmanFlat);
		}).then(function(){
			return dispatcher.calculateGamePlayersScores(game.address);
		}).then(function(){
			return dispatcher.sortGamePlayers(game.address);
		}).then(function(){
			return dispatcher.calculateGameWinners(game.address);
		}).then(function(){
			return game.playerScoreBy.call(0);
		}).then(function(score){
			assert.equal(score.valueOf(), 650, "team [1,2,3] has 650 scores");
			return game.playerScoreBy.call(1);
		}).then(function(score){
			assert.equal(score.valueOf(), 410, "team [3,4,5] has 410 scores");
			return game.playerPrizeBy.call(0);
		}).then(function(prize){
			assert.equal(prize.valueOf(), 4, "team [1,2,3] has 4 tokens prize");
			return game.playerPrizeBy.call(1);
		}).then(function(prize){
			assert.equal(prize.valueOf(), 2, "team [3,4,5] has 2 tokens prize");
			return dispatcher.updateGameUsersStats(game.address);
		}).then(function(){
			return dispatcher.sendGamePrizes(game.address);
		}).then(function(){
			return Stats.deployed().then(function(instance){
				stats = instance;
				return stats.users.call(account_one);
			}).then(function(user){
				assert.equal(user[0].toNumber(), 2, "user play 2 commands");
				assert.equal(user[1].toNumber(), 2, "user has 2 winner places");
				assert.equal(user[2].toNumber(), 6, "user win 6 tokens");
				assert.equal(user[3].toNumber(), 10, "user pay 10 tokens");
			})
		})
	});
});