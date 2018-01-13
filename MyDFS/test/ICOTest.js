var GenericCrowdsale = artifacts.require("GenericCrowdsale");
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
        	var token = await MyDFSToken.new({from: accounts[0]});
			var instance = await GenericCrowdsale.new(address(0), token.address);
			assert.fail("Create should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("Pre ICO Works", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var state = await instance.state.call();
		assert.equal(state.toNumber(), 0);

		await instance.preIco(10, 3, 1e3, [], []);
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

	it("ICO Works", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var state = await instance.state.call();
		assert.equal(state.toNumber(), 0);

		await instance.ico(10, 100, 3, 1e3, [], []);
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

	it("ICO Bonuses Works", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [], []);

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(9),
		    gas: 5000000
		});
		await sleep(3000);
		await instance.claimBonus({from: investor, gas: 5000000});
		const boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 9220);
	});

	it("ICO Bonuses Works 2", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [], []);

		var investor1 = accounts[1];
		var investor2 = accounts[2];
		var investor3 = accounts[3];

		await web3.eth.sendTransaction({
		    from: investor1,
		    to: instance.address,
		    value: web3.toWei(6),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor2,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor3,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		
		await sleep(2000);
		await instance.claimBonus({from: investor1, gas: 5000000});
		await instance.claimBonus({from: investor2, gas: 5000000});
		await instance.claimBonus({from: investor3, gas: 5000000});

		boughtTokens = await token.balanceOf(investor1);
		assert.equal(boughtTokens.toNumber(), 6200);
		boughtTokens = await token.balanceOf(investor2);
		assert.equal(boughtTokens.toNumber(), 1010);
		boughtTokens = await token.balanceOf(investor3);
		assert.equal(boughtTokens.toNumber(), 2010);
	});

	it("refund works if soft goal not reached", async function() {
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [], []);

		var investor = accounts[1];

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 1000000
		});

		await sleep(3000);
		try{
			await instance.withdrawFunding({from: accounts[0]});
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
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(1000, 10000, 3, 1e6, [], []);

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

		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(1, 10000, 5, 1e6, [], []);

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(sum),
		    gas: 1000000
		});
		
		await sleep(5000);
		const start_balance = web3.eth.getBalance(accounts[0]).toNumber();
		await instance.withdrawFunding({from: accounts[0]});
		const after_balance = web3.eth.getBalance(accounts[0]).toNumber();
		assert.ok(after_balance != start_balance);
	});

	it("Foreign purchase works", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [], []);

		var investor = accounts[1];
		instance.foreignPurchase(investor, 1e18, {from : accounts[0]});
		const boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 1000);
	});

	it("ICO Discounts Works", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [3000, 1000], [20, 5]);

		var investor1 = accounts[1];
		var investor2 = accounts[2];
		var investor3 = accounts[3];

		await web3.eth.sendTransaction({
		    from: investor1,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor2,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor3,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		
		await sleep(2000);
		await instance.claimBonus({from: investor1, gas: 5000000});
		await instance.claimBonus({from: investor2, gas: 5000000});
		await instance.claimBonus({from: investor3, gas: 5000000});

		boughtTokens = await token.balanceOf(investor1);
		assert.equal(boughtTokens.toNumber(), 3650);
		boughtTokens = await token.balanceOf(investor2);
		assert.equal(boughtTokens.toNumber(), 1060);
		boughtTokens = await token.balanceOf(investor3);
		assert.equal(boughtTokens.toNumber(), 2100);
	});

	it("ICO Discounts Works 2", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		await instance.ico(2, 20, 3, 1e3, [3000], [5]);

		var investor1 = accounts[1];
		var investor2 = accounts[2];
		var investor3 = accounts[3];

		await web3.eth.sendTransaction({
		    from: investor1,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor2,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 5000000
		});
		await web3.eth.sendTransaction({
		    from: investor3,
		    to: instance.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		await sleep(2000);

		await instance.claimBonus({from: investor1, gas: 5000000});
		try{
			await instance.claimBonus({from: investor1, gas: 5000000});
			assert.fail("Retry claim bonus should throw error");
		}  catch(error) {
            assert.ok(true);
        }

		await instance.claimBonus({from: investor2, gas: 5000000});
		await instance.claimBonus({from: investor3, gas: 5000000});

		boughtTokens = await token.balanceOf(investor1);
		assert.equal(boughtTokens.toNumber(), 3200);
		boughtTokens = await token.balanceOf(investor2);
		assert.equal(boughtTokens.toNumber(), 1010);
		boughtTokens = await token.balanceOf(investor3);
		assert.equal(boughtTokens.toNumber(), 2000);
	});
});

//test test/ICOTest.js