var GenericCrowdsale = artifacts.require("GenericCrowdsaleMock");
var MyDFSToken = artifacts.require("MyDFSToken");

contract('GenericCrowdsale', function(accounts){

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

	it("create should fail", async function(){
		var token = await MyDFSToken.new();
		try{
			await GenericCrowdsale.new(accounts[0], address(0));
			assert.fail("Create should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
        	var token = await MyDFSToken.new();
			var instance = await GenericCrowdsale.new(address(0), token.address);
			assert.fail("Create should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("Pre ICO Works", async function(){
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);

		var state = await instance.state.call();
		assert.equal(state.toNumber(), 0);

		await instance.preIco(10, 3, 1e15, [], []);
		var state = await instance.state.call();
		assert.equal(state.toNumber(), 1);

		var investor = accounts[2];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		await sleep(3000);

		boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 4285);

		try{
        	await web3.eth.sendTransaction({
			    from: investor,
			    to: instance.address,
			    value: web3.toWei(3),
			    gas: 5000000
			});
			assert.fail("Purchase should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("ICO Works", async function(){
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);

		var state = await instance.state.call();
		assert.equal(state.toNumber(), 0);

		await instance.ico(1, 3, 10, 1e15, [], []);
		var state = await instance.state.call();
		assert.equal(state.toNumber(), 2);

		var investor = accounts[2];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		await sleep(3000);

		boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 3000);

		try{
        	await web3.eth.sendTransaction({
			    from: investor,
			    to: instance.address,
			    value: web3.toWei(3),
			    gas: 5000000
			});
			assert.fail("Purchase should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("refund works if soft goal not reached", async function() {
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(2, 20, 3, 1e9, [], []);

		var investor = accounts[1];

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 1000000
		});

		await sleep(3000);
		try{
			await instance.withdrawFunding();
			assert.fail("withdraw Funding should throw error");
		} catch(error) {
	        assert.ok(true);
	    }

		var initialBalance = web3.eth.getBalance(investor).toNumber();
		await instance.claimRefund({from: investor});
		balance = web3.eth.getBalance(investor).toNumber();
		assert.ok(balance != initialBalance);
	});

	it("refund NOT works if soft goal reached", async function(){
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(1000, 10000, 3, 1e9, [], []);

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 1000000
		});

		await sleep(3000);
		try{
			await instance.claimRefund({from: investor});
			assert.fail("withdraw Funding should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("withdraw works correctly", async function(){
		const sum = 2;

		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(1, 10000, 5, 1e9, [], []);

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(sum),
		    gas: 1000000
		});
		
		await sleep(5000);
		const start_balance = web3.eth.getBalance(accounts[0]).toNumber();
		await instance.withdrawFunding();
		const after_balance = web3.eth.getBalance(accounts[0]).toNumber();
		assert.ok(after_balance != start_balance);
	});

	it("Foreign purchase works", async function(){
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(2, 20, 3, 1e12, [], []);

		var investor = accounts[1];
		instance.foreignPurchase(investor, 1e15);
		const boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 1000);
	});

	it("overhead correctly works", async function(){
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(1, 2, 3, 1e15, [], []);

		var investor = accounts[2];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		await sleep(3000);

		boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 2000);
	});

	it("send dev tokens", async function() {
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(1, 10, 3, 1e9, [], []);

		try{
			await instance.sendDevTokens();
			assert.fail("Send dev tokens before ICO success should throw error");
		}  catch(error) {
            assert.ok(true);
        }

		var investor = accounts[2];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});

		await sleep(3000);

		await instance.sendDevTokens();
		var tokensHolderAddress = await instance.devTokensHolder();
		tokens_balance = await token.balanceOf(tokensHolderAddress.valueOf());
		assert.equal(tokens_balance.toNumber(), 12500 * 1e9);
	});

	it("send advisors tokens", async function() {
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(1, 10, 3, 1e9, [], []);

		try{
			await instance.sendAdvisorsTokens();
			assert.fail("Send advisors tokens before ICO success should throw error");
		}  catch(error) {
            assert.ok(true);
        }

		var investor = accounts[2];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});

		await sleep(3000);

		await instance.sendAdvisorsTokens();
		var tokensHolderAddress = await instance.advisorsTokensHolder();
		tokens_balance = await token.balanceOf(tokensHolderAddress.valueOf());
		assert.equal(tokens_balance.toNumber(), 12500 * 1e9);
	});

	it("ICO Discounts Works", async function() {
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(2, 20, 10, 1e15, [3, 1], [20, 5]);

		var investor1 = accounts[3];
		var investor2 = accounts[2];

		await web3.eth.sendTransaction({
		    from: investor1,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		boughtTokens = await token.balanceOf(investor1);
		assert.equal(boughtTokens.toNumber(), 3600);

		await web3.eth.sendTransaction({
		    from: investor2,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		boughtTokens = await token.balanceOf(investor2);
		assert.equal(boughtTokens.toNumber(), 2100);
	});

	it("ICO week price works", async function() {
		var token = await MyDFSToken.new();
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 125 * 1e12);
		await instance.ico(2, 20, 86400 * 28, 1e15, [3, 1], [20, 5]);

		var deadline = await instance.deadline();
		const t = deadline.toNumber() - (86400 * 20);
        await instance.setMockedTime(t);

		var investor = accounts[1];

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 3000);
	});

});

//test test/ICOTest.js