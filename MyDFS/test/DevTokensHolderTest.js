const GenericCrowdsale = artifacts.require("GenericCrowdsale");
const MyDFSToken = artifacts.require("MyDFSToken");
const DevTokensHolder = artifacts.require("DevTokensHolderMock");

contract('DevTokensHolder', function(accounts){
	const addressOwner = accounts[0];
	const addressDevs = accounts[2];
	const investor = accounts[3];

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

    it("Allows devs to extract token part after 3 months", async function() {
		var token = await MyDFSToken.new();
		const totalSupply = await token.totalSupply();
		var crowdsale = await GenericCrowdsale.new(accounts[1], token.address);
		await token.transfer(crowdsale.address, totalSupply.mul(0.95));
		await crowdsale.ico(1, 10, 3, 5, [], []);

		try{
			await crowdsale.sendDevTokens({from: accounts[0]});
			assert.fail("Send dev tokens before ICO success should throw error");
		}  catch(error) {
            assert.ok(true);
        }

		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});

		var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, accounts[0]);
		await token.transfer(devTokensHolder.address, totalSupply.mul(0.05));

		//change current time to 3 month later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 90);
        await devTokensHolder.setMockedTime(t);
        await devTokensHolder.collectTokens();
        const balance = await token.balanceOf(addressOwner);

        const calcTokens = web3.fromWei(totalSupply.mul(0.05).mul(0.25)).toNumber();
        const realTokens = web3.fromWei(balance).toNumber();

        assert.equal(realTokens, calcTokens);
    });

    it("Disallows devs from transfering before 14 days have past", async function() {
		var token = await MyDFSToken.new();
		const totalSupply = await token.totalSupply();
		var crowdsale = await GenericCrowdsale.new(accounts[1], token.address);

		await token.transfer(crowdsale.address, totalSupply.mul(0.95));
		await crowdsale.ico(1, 10, 3, 5, [], []);
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});

		var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, accounts[0]);
		await token.transfer(devTokensHolder.address, totalSupply.mul(0.05));

		//change current time to 13 days later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 13);
        await devTokensHolder.setMockedTime(t);

        try{
        	await devTokensHolder.collectTokens({from: addressOwner});
        	assert.fail("Send dev tokens before 14 days should throw error");
		}  catch(error) {
            assert.ok(true);
        }
    });

    it("Allows devs to extract everything after 12 months", async function() {
		var token = await MyDFSToken.new();
		const totalSupply = await token.totalSupply();
		var crowdsale = await GenericCrowdsale.new(accounts[1], token.address);

		await token.transfer(crowdsale.address, totalSupply.mul(0.95));
		await crowdsale.ico(1, 10, 3, 5, [], []);
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});

		var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, accounts[0]);
		await token.transfer(devTokensHolder.address, totalSupply.mul(0.05));

		//change current time to 12 month later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 360);
        await devTokensHolder.setMockedTime(t);
        await devTokensHolder.collectTokens({from: addressOwner});
        const balance = await token.balanceOf(addressOwner);

        const calcTokens = web3.fromWei(totalSupply.mul(0.05)).toNumber();
        const realTokens = web3.fromWei(balance).toNumber();

        assert.equal(realTokens, calcTokens);
    });

});

//test test/DevTokensHolderTest.js