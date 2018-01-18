var MyDFSToken = artifacts.require("MyDFSToken");
var DispatcherTest = artifacts.require("DispatcherTest");


contract('DispatcherTest', function(accounts){

	it("check", async function() {
		var gameId = 1;
		var token = await MyDFSToken.new();
		var dispatcher = await DispatcherTest.new(token.address);

		for (var i = 1; i <= 10; i++) {
			await dispatcher.registerUser(i, i);
		}
		
		var gasUsed = await dispatcher.createGame(gameId, 2, 5);
		console.log(gasUsed);
		gasUsed = await dispatcher.participateGame([1,2,3,4,5,6,7,8,9,10], gameId);
		console.log(gasUsed);
		await dispatcher.startGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
		try {
			await dispatcher.startGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
			assert.fail("Start retry should throw error");
		} catch(error) {
            assert.ok(true);
        }

		await dispatcher.finishGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');

		try {
			await dispatcher.cancelGame(gameId);
			assert.fail("Cancel should throw error");
		} catch(error) {
            assert.ok(true);
        }

        try {
			await dispatcher.finishGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
			assert.fail("Finish retry should throw error");
		} catch(error) {
            assert.ok(true);
        }
	});

});

//test test/GasTest.js