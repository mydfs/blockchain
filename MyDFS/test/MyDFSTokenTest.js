var MyDFSToken = artifacts.require("MyDFSToken");

contract('MyDFSToken', function(accounts){
	it("Owner should have 100000 tokens initially", async function(){
		var token = await MyDFSToken.new();
		var balance = await token.balanceOf.call(accounts[0]);
		assert.equal(balance.toNumber(), 1 * 1e9, "Owner should have 100000 tokens initially");
	});

	it("should send coin correctly", async function() {
	    var token = await MyDFSToken.new();

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[1];
	    var amount = 10000;

    	var one_starting_balance = await token.balanceOf.call(account_one);
    	var two_starting_balance = await token.balanceOf.call(account_two);
    	
    	await token.transfer(account_two, amount, {from: account_one});
    	
    	var one_ending_balance = await token.balanceOf.call(account_one);
    	var two_ending_balance = await token.balanceOf.call(account_two);

    	assert.equal(one_ending_balance.toNumber(), one_starting_balance.toNumber() - amount, "first should have balance - <amount> tokens");
    	assert.equal(two_ending_balance.toNumber(), two_starting_balance.toNumber() + amount, "second should have balance + <amount> tokens");
	});

	it("should increase allowance correctly", async function() {
	    var token = await MyDFSToken.new();

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[2];
	    var amount = 10000;

    	var one_starting_balance = await token.balanceOf.call(account_one);
    	var two_starting_balance = await token.balanceOf.call(account_two);

    	await token.increaseApproval(account_two, amount, {from: account_one});

    	var allowance = await token.allowance.call(account_one, account_two);
    	assert(allowance.toNumber(), amount, "allowance is <amount> tokens");
    	
    	await token.transferFrom(account_one, account_two, amount, {from: account_two});
    	var one_ending_balance = await token.balanceOf.call(account_one);
    	var two_ending_balance = await token.balanceOf.call(account_two);

    	assert.equal(one_ending_balance.toNumber(), one_starting_balance.toNumber() - amount, "first should have balance - <amount> tokens");
    	assert.equal(two_ending_balance.toNumber(), two_starting_balance.toNumber() + amount, "second should have balance + <amount> tokens");
	});

	it("should denied overhead allowance correctly", async function() {
	    var token = await MyDFSToken.new();

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[2];
	    var amount = 10000;

    	var one_starting_balance = await token.balanceOf.call(account_one);
    	var two_starting_balance = await token.balanceOf.call(account_two);

    	await token.increaseApproval(account_two, amount, {from: account_one});

    	var allowance = await token.allowance.call(account_one, account_two);
    	assert(allowance.toNumber(), amount, "allowance is <amount> tokens");
    	
    	try{
    		await token.transferFrom(account_one, account_two, amount + 1, {from: account_two});
    		assert.fail("Create should throw error");
    	}  catch(error) {
            assert.ok(true);
        }
    	var one_ending_balance = await token.balanceOf.call(account_one);
    	var two_ending_balance = await token.balanceOf.call(account_two);

    	assert.equal(one_ending_balance.toNumber(), one_starting_balance.toNumber(), "first should have balance without changes");
    	assert.equal(two_ending_balance.toNumber(), two_starting_balance.toNumber(), "second should have balance without changes");
	});
});