const Dispatcher = artifacts.require("Dispatcher");
const MyDFSToken = artifacts.require("MyDFSToken");

contract('Dispatcher', function(accounts){
	var user = accounts[2];
	var userId = 3;
	var teamId = 78;
	var gameId = 102;

	it("user register and deposit tokens", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);
		await token.transfer(user, 1000);

		await dispatcher.registerUser(user, userId);
		var gameBalance = await dispatcher.balanceOf(user);
		assert.equal(0, gameBalance.toNumber());

		await token.transfer(dispatcher.address, 1000, {from: user});
		gameBalance = await dispatcher.balanceOf(user);
		assert.equal(1000, gameBalance.toNumber());

		gameBalance = await dispatcher.balances(userId);
		assert.equal(1000, gameBalance.toNumber());
	});

	it("game create sucessfully", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		var dueDate = Date.now() / 1000 + 10;
		await dispatcher.createGame(gameId, 10, 10, dueDate);
	});

	it("game participation", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		//register user and deposit tokens
		await token.transfer(user, 1000);
		await dispatcher.registerUser(user, userId);
		await token.transfer(dispatcher.address, 1000, {from: user});

		var dueDate = Math.round(Date.now() / 1000) + 10;
		console.log(dueDate);
		await dispatcher.createGame(gameId, 10, 10, dueDate);
		await dispatcher.participateGame(gameId, teamId, userId, 0);
	});

	it("game start", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		var dueDate = Date.now() / 1000 + 10;
		await dispatcher.createGame(gameId, 10, 10, dueDate);
		await dispatcher.startGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
	});

	it("game finish", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		var dueDate = Date.now() / 1000 + 10;
		await dispatcher.createGame(gameId, 10, 10, dueDate);
		await dispatcher.startGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
		await dispatcher.finishGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
	});

	it("game winners", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		//register user and deposit tokens
		await token.transfer(user, 1000);
		await dispatcher.registerUser(user, userId);
		await token.transfer(dispatcher.address, 1000, {from: user});

		var dueDate = Math.round(Date.now() / 1000) + 10;
		console.log(dueDate);
		await dispatcher.createGame(gameId, 10, 10, dueDate);
		await dispatcher.participateGame(gameId, teamId, userId, 0);

		await dispatcher.startGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
		await dispatcher.finishGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
		await dispatcher.winners(gameId, [teamId], [10]);

		gameBalance = await dispatcher.balances(userId);
		assert.equal(1000, gameBalance.toNumber());
	});

	it("cancelled game refund", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);

		//register user and deposit tokens
		await token.transfer(user, 1000);
		await dispatcher.registerUser(user, userId);
		await token.transfer(dispatcher.address, 1000, {from: user});

		var dueDate = Math.round(Date.now() / 1000) + 10;
		console.log(dueDate);
		await dispatcher.createGame(gameId, 10, 10, dueDate);
		await dispatcher.participateGame(gameId, teamId, userId, 0);

		await dispatcher.startGame(gameId, '57136f0a3d87e187624c0adb30ff2fbdcf47ac9613b1ba46b870e57fa3b5f89c');
		await dispatcher.cancelGame(gameId);
		await dispatcher.refundCancelledGame(gameId, [teamId]);

		gameBalance = await dispatcher.balances(userId);
		assert.equal(1000, gameBalance.toNumber());
	});

	it("withdraw", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);
		await token.transfer(user, 1000);

		await dispatcher.registerUser(user, userId);
		await token.transfer(dispatcher.address, 1000, {from: user});

		gameBalance = await dispatcher.balances(userId);
		assert.equal(1000, gameBalance.toNumber());

		await dispatcher.withdraw(1000, {from: user});

		gameBalance = await dispatcher.balances(userId);
		assert.equal(0, gameBalance.toNumber());
	});

	it("system withdraw", async function(){
		var token = await MyDFSToken.new();
		var dispatcher = await Dispatcher.new(token.address);
		await token.transfer(user, 1000);

		await dispatcher.registerUser(user, userId);
		await token.transfer(dispatcher.address, 1000, {from: user});

		gameBalance = await dispatcher.balances(userId);
		assert.equal(1000, gameBalance.toNumber());

		await dispatcher.systemWithdraw(user, 1000);

		gameBalance = await dispatcher.balances(userId);
		assert.equal(0, gameBalance.toNumber());
	});
});

//test test/DispatcherTest.js