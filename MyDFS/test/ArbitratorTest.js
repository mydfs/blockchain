var MyDFSToken = artifacts.require("MyDFSToken");
var Arbitrator = artifacts.require("Arbitrator");


contract('Arbitrator', function(accounts){

	it("check", async function() {
		var gameId = 1;
		var token = await MyDFSToken.new();
		var dispatcher = await Arbitrator.new(token.address);
		
		var gasUsed = await dispatcher.createGame(gameId, 2, 5, 1932848);
		console.log(gasUsed);
		var gasUsed = await dispatcher.startGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
		console.log(gasUsed);
		
		try {
			await dispatcher.startGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
			assert.fail("Start retry should throw error");
		} catch(error) {
            assert.ok(true);
        }

		var gasUsed = await dispatcher.finishGame(gameId, 'bc6dc48b743dc5d013b1abaebd2faed2');
		console.log(gasUsed);

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

//test test/ArbitratorTest.js