var ICO = artifacts.require("ICO");
var MyDFSToken = artifacts.require("MyDFSToken");

contract('ICO', function(accounts){

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

	it("create should fail", async function(){
		var token = await MyDFSToken.new();
		try{
			await ICO.new(accounts[0], 1000, 100, 60, 1e6, token.address);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(accounts[0], -10, 100, 60, 1e6, token.address);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(accounts[0], 100, -100, 60, 1e6, token.address);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(accounts[0], 10, 100, 0, 1e6, token.address);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(address(0), 10, 100, 60, 0, token.address);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(accounts[0], 10, 100, 60, 1e6, address(0));
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("bonuses", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(accounts[0], 2, 20, 3, 1e3, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(3),
		    gas: 500000
		});
		await sleep(3000);
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		const boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 3020);
	});


	it("bonuses2", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(accounts[0], 2, 20, 3, 1e3, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(9),
		    gas: 5000000
		});
		await sleep(3000);
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		var bonus_send = await instance.distributeBonuses.call({from: accounts[0], gas: 5000000});
		assert.isFalse(bonus_send.valueOf(), 'no bonus');
		const boughtTokens = await token.balanceOf(investor);
		assert.equal(boughtTokens.toNumber(), 9220);
	});

	it("bonuses3", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(accounts[0], 2, 20, 3, 1e3, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

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
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		await instance.distributeBonuses({from: accounts[0], gas: 5000000});
		var bonus_send = await instance.distributeBonuses.call({from: accounts[0], gas: 5000000});
		assert.isFalse(bonus_send.valueOf(), 'bonus distributed');
		boughtTokens = await token.balanceOf(investor1);
		assert.equal(boughtTokens.toNumber(), 3050);
		boughtTokens = await token.balanceOf(investor2);
		assert.equal(boughtTokens.toNumber(), 1010);
		boughtTokens = await token.balanceOf(investor3);
		assert.equal(boughtTokens.toNumber(), 2000);
	});

	it("refund works if soft goal not reached", async function() {
		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(accounts[0], 1000, 10000, 3, 1e6, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

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
		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(accounts[0], 1000, 10000, 3, 1e6, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});
		
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

		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(accounts[0], 1, 10000, 5, 1e6, token.address);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

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
});

//test test/ICOTest.js