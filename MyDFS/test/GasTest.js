var MyDFSToken = artifacts.require("MyDFSToken");
var DispatcherTest = artifacts.require("DispatcherTest");


contract('DispatcherTest', function(accounts){

	it("check", async function() {
		var token = await MyDFSToken.new();
		var dispatcher = await DispatcherTest.new(token);

		for (var i = 1; i <= 10; i++) {
			await dispatcher.addUser(i, i);
		}
		var gasUsed = await dispatcher.createGame(1, 2, 5, 1984);
		console.log(gasUsed);
		gasUsed =await dispatcher.participateGame([1,2,3,4,5,6,7,8,9,10], 1);
		console.log(gasUsed);
	});

});

//test test/GasTest.js