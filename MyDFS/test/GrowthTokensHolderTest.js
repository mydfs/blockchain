const GenericCrowdsale = artifacts.require("GenericCrowdsale");
const MyDFSToken = artifacts.require("MyDFSToken");
const GrowthTokensHolder = artifacts.require("GrowthTokensHolderMock");

contract('GrowthTokensHolder', function(accounts){
	const addressOwner = accounts[0];
	const addressDevs = accounts[2];
	const investor = accounts[3];

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

    it("Disallows devs from transfering before 14 days have past", async function() {
		var token = await MyDFSToken.new();
		const totalSupply = await token.totalSupply();
		var crowdsale = await GenericCrowdsale.new(accounts[1], token.address);

		await token.transfer(crowdsale.address, totalSupply.mul(0.8));
		await crowdsale.ico(1, 10, 3, 5, [], []);
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});

		var tokensHolder = await GrowthTokensHolder.new(crowdsale.address, token.address, accounts[0]);
		await token.transfer(tokensHolder.address, totalSupply.mul(0.1));

		//change current time to 13 days later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 13);
        await tokensHolder.setMockedTime(t);

        try{
        	await tokensHolder.collectTokens({from: addressOwner});
        	assert.fail("Send dev tokens before 14 days should throw error");
		}  catch(error) {
            assert.ok(true);
        }
    });

    it("Allows devs to extract everything after 15 days", async function() {
		var token = await MyDFSToken.new();
		const totalSupply = await token.totalSupply();
		var crowdsale = await GenericCrowdsale.new(accounts[1], token.address);

		await token.transfer(crowdsale.address, totalSupply.mul(0.9));
		await crowdsale.ico(1, 10, 3, 5, [], []);
		await web3.eth.sendTransaction({
		    from: investor,
		    to: crowdsale.address,
		    value: web3.toWei(3),
		    gas: 5000000
		});

		var tokensHolder = await GrowthTokensHolder.new(crowdsale.address, token.address, accounts[0]);
		await token.transfer(tokensHolder.address, totalSupply.mul(0.1));

		//change current time to 15 days later
		var deadline = await crowdsale.deadline();
		const t = deadline.toNumber() + (86400 * 15);
        await tokensHolder.setMockedTime(t);
        await tokensHolder.collectTokens({from: addressOwner});
        const balance = await token.balanceOf(addressOwner);

        const calcTokens = web3.fromWei(totalSupply.mul(0.1)).toNumber();
        const realTokens = web3.fromWei(balance).toNumber();

        assert.equal(realTokens, calcTokens);
    });

});

//test test/DevTokensHolderTest.js