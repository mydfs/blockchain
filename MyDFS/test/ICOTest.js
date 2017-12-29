var ICO = artifacts.require("ICO");
var MyDFSToken = artifacts.require("MyDFSToken");

contract('ICO', function(accounts){
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
		console.log(initialBalance);

		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(1),
		    gas: 150000
		});
		const boughtTokens = await token.balanceOf(investor);
		console.log(boughtTokens.toNumber());
		const balance = web3.eth.getBalance(investor).toNumber();
		console.log(balance);
		assert.equal(boughtTokens.toNumber(), 2);
	});

	/*it("iCO refund works if soft goal not reached", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(token.address, 10, 1000, 2, 1e9, token.address, [1, 10, 100], [5, 10, 15]);
		
		var investor = accounts[1];
		const before_balance = web3.eth.getBalance(investor).toNumber();
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(9)
		});
		this.slow(2000);
		try{
			await instance.withdrawFunding({from: accounts[0]});
			assert.fail("withdraw Funding should throw error");
		}  catch(error) {
            assert.ok(true);
        }
		await instance.claimRefund({from: investor});
		const balance = web3.eth.getBalance(investor).toNumber();
		assert.equal(balance, before_balance);
	});

	it("iCO refund NOT works if soft goal reached", async function(){
		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(token.address, 10, 1000, 2, 1e9, token.address, [1, 10, 100], [5, 10, 15]);
		
		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(11)
		});
		this.slow(2000);
		try{
			await instance.claimRefund({from: investor});
			assert.fail("withdraw Funding should throw error");
		}  catch(error) {
            assert.ok(true);
        }
	});

	it("iCO withdraw works correctly", async function(){
		const start_balance = web3.eth.getBalance(accounts[0]).toNumber();
		const sum = 11;

		var token = await MyDFSToken.new({from: accounts[0]});
		var instance = await ICO.new(token.address, 10, 1000, 2, 1e9, token.address, [1, 10, 100], [5, 10, 15]);
		var investor = accounts[1];
		await web3.eth.sendTransaction({
		    from: investor,
		    to: instance.address,
		    value: web3.toWei(sum)
		});
		this.slow(2000);
		await instance.withdrawFunding({from: accounts[0]});
		const after_balance = web3.eth.getBalance(accounts[0]).toNumber();
		assert.equal(sum, after_balance - start_balance);
	});*/
});

//test test/ICOTest.js