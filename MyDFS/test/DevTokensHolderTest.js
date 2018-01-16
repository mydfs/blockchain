const GenericCrowdsale = artifacts.require("GenericCrowdsale");
const MyDFSToken = artifacts.require("MyDFSToken");
const DevTokensHolder = artifacts.require("DevTokensHolderMock");

contract('DevTokensHolder', function(accounts){
	const addressOwner = accounts[1];
	const addressDevs = accounts[2];
	const investor = accounts[3];

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

	it("Disallows devs from transfering before successed ICO", async function() {
		var token = await MyDFSToken.new({from : addressOwner});
		var crowdsale = await GenericCrowdsale.new(addressOwner, token.address);
		await token.transfer(crowdsale.address, 11500, {from : addressOwner});
		await crowdsale.ico(10, 100, 3600, 1e3, [], []);

		try{
			var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, {from : addressOwner});
	        await devTokensHolder.collectTokens({from: addressOwner});
	        assert.fail("Token transfer should throw error");
        }  catch(error) {
            assert.ok(true);
        }

        const balance = await token.balanceOf(addressDevs);
        assert.equal(balance,0);
    });

    it("Allows devs to extract token part after 3 months", async function() {
		var token = await MyDFSToken.new({from : addressOwner});
        const totalSupply = await token.totalSupply();

        //initialize Crowdsale and dev holder wallet
		var crowdsale = await GenericCrowdsale.new(addressOwner, token.address, {from : addressOwner});
		await token.transfer(crowdsale.address, totalSupply.mul(0.8), {from : addressOwner});
		var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, {from : addressDevs});
		await token.transfer(devTokensHolder.address, totalSupply.mul(0.05), {from : addressOwner});

		//run and success ICo
        await crowdsale.ico(1, 10, 2, 1e3, [], [], {from : addressOwner});
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		await sleep(3000);

		//change current time to 3 month later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 90);
        await devTokensHolder.setMockedTime(t);
        await devTokensHolder.collectTokens({from: addressDevs});
        const balance = await token.balanceOf(addressDevs);

        const calcTokens = web3.fromWei(totalSupply.mul(0.05).mul(0.25)).toNumber();
        const realTokens = web3.fromWei(balance).toNumber();

        assert.equal(realTokens, calcTokens);
    });

    it("Allows devs to extract everything after 12 months", async function() {
		var token = await MyDFSToken.new({from : addressOwner});
        const totalSupply = await token.totalSupply();

        //initialize Crowdsale and dev holder wallet
		var crowdsale = await GenericCrowdsale.new(addressOwner, token.address, {from : addressOwner});
		await token.transfer(crowdsale.address, totalSupply.mul(0.8), {from : addressOwner});
		var devTokensHolder = await DevTokensHolder.new(crowdsale.address, token.address, {from : addressDevs});
		await token.transfer(devTokensHolder.address, totalSupply.mul(0.05), {from : addressOwner});

		//run and success ICo
        await crowdsale.ico(1, 10, 2, 1e3, [], [], {from : addressOwner});
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(2),
		    gas: 5000000
		});
		await sleep(3000);

		//change current time to 12 month later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 360);
        await devTokensHolder.setMockedTime(t);
        await devTokensHolder.collectTokens({from: addressDevs});
        const balance = await token.balanceOf(addressDevs);

        const calcTokens = web3.fromWei(totalSupply.mul(0.05)).toNumber();
        const realTokens = web3.fromWei(balance).toNumber();

        assert.equal(realTokens, calcTokens);
    });

});

//test test/DevTokensHolderTest.js