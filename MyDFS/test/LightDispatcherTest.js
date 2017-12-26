var Dispatcher = artifacts.require("Dispatcher.sol");
var MyDFSToken = artifacts.require("MyDFSToken");
var Game = artifacts.require("Game");

contract('Dispatcher', function(accounts){
	var dispatcherAddress;

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
			return Dispatcher.deployed().then(function(instance){
				dispatcher = instance;
				dispatcherAddress = dispatcher.address;
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
		})
	});

	it("game work correctly", function(){
		var dispatcher;
		var game;

		var account_one = accounts[0];

		var entry_value = 5;
		var service_fee_percent = 20;
		var small_game_prizes_percent = [50, 30, 20];
		var large_game_prizes_percent = [40, 30, 20, 10];

		var team_one = [1, 2, 3];
		var team_two = [3, 4, 5];

		return Dispatcher.at(dispatcherAddress).then(function(instance){
			dispatcher = instance;
			return dispatcher.createGame.call(entry_value, service_fee_percent, small_game_prizes_percent, large_game_prizes_percent, {from: account_one});
		}).then(function(gameAddress){
			assert.notEqual(gameAddress, 0, "game address is not 0");
			game = Game.at(gameAddress);
			return game.gameState.call();
		}).then(function(state){
			assert.equal(state.toNumber(), 0, "game state is team creation");
			return game.serviceFee.call();
		}).then(function(serviceFee){
			console.log(serviceFee.valueOf());
			// return dispatcher.addParticipant(account_one, team_one, game.address);
		// }).then(function(){
		// 	return dispatcher.teamsCountOf.call(account_one);
		// }).then(function(count){
		// 	assert.equal(count, 1, "account_one has 1 team");
		// 	return dispatcher.addParticipant(account_one, team_two, game.address);
		// }).then(function(){
		// 	return dispatcher.teamsCountOf.call(account_one);
		// }).then(function(count){
		// 	assert.equal(count, 2, "account_one has 2 teams");
		// 	return game.gameState.call();
		// }).then(function(state){
		// 	assert.equal(state.toNumber(), 0, "game state is still team creation");
		});
	});
});