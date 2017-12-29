var ICO = artifacts.require("ICO");
var MyDFSToken = artifacts.require("MyDFSToken");

contract('ICO', function(accounts){

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

	it("iCO create should fail", async function(){
		var token = await MyDFSToken.new();
		try{
			await ICO.new(token.address, 1000, 100, 60, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(token.address, -10, 100, 60, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(token.address, 100, -100, 60, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(token.address, 10, 100, 0, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(address(0), 10, 100, 60, 0, token.address, [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(token.address, 10, 100, 60, 1e6, address(0), [1, 10, 100], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }

        try{
			await ICO.new(token.address, 10, 100, 60, 1e6, token.address, [1, 10], [5, 10, 15]);
			assert.fail("Create ICO should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("iCO bonuses", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(token.address, 1000, 10000, 60, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var investor = accounts[1];
		const initialBalance = web3.eth.getBalance(investor).toNumber();

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(10),
		    gas: 100000
		});
		const boughtTokens = await token.balanceOf(investor);
		const balance = web3.eth.getBalance(investor).toNumber();
		assert.equal(boughtTokens.toNumber(), 11);
	});

	it("iCO bonuses again", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(token.address, 1000, 10000, 60, 1e6, token.address, [1, 5, 10], [5, 10, 20]);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var investor = accounts[1];
		const initialBalance = web3.eth.getBalance(investor).toNumber();

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(10),
		    gas: 100000
		});
		const boughtTokens = await token.balanceOf(investor);
		const balance = web3.eth.getBalance(investor).toNumber();
		assert.equal(boughtTokens.toNumber(), 12);
	});*/

	/*it("iCO refund works if soft goal not reached", async function() {
		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(token.address, 1000, 10000, 3, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
		await token.transfer(instance.address, 11500, {from : accounts[0]});

		var investor = accounts[1];
		//const initialBalance = web3.eth.getBalance(investor).toNumber();

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

	it("iCO refund NOT works if soft goal reached", async function(){
		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(token.address, 1000, 10000, 3, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
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

	it("iCO withdraw works correctly", async function(){
		//const start_balance = web3.eth.getBalance(accounts[0]).toNumber();
		const sum = 2;

		const token = await MyDFSToken.new({from: accounts[0]});
		const instance = await ICO.new(accounts[0], 1, 10000, 5, 1e6, token.address, [1, 10, 100], [5, 10, 15]);
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