var MyDFSToken = artifacts.require("MyDFSToken");

contract('MyDFSToken', function(accounts){
	it("Owner should have 100000 tokens initially", function(){
		return MyDFSToken.deployed().then(function(instance){
			return instance.balanceOf.call(accounts[0]);
		}).then(function(balance){
			assert.equal(balance.valueOf(), 100000, "Owner should have 100000 tokens initially");
		});
	});

	it("should send coin correctly", function() {
	    var token;

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[1];

	    var one_starting_balance;
	    var two_starting_balance;
	    var one_ending_balance;
	    var two_ending_balance;

	    var amount = 10000;

	    return MyDFSToken.deployed().then(function(instance) {
	    	token = instance;
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_starting_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_starting_balance = balance.toNumber();
	    	return token.transfer(account_two, amount, {from: account_one});
	    }).then(function() {
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_ending_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_ending_balance = balance.toNumber();

	    	assert.equal(one_ending_balance, one_starting_balance - amount, "first should have balance - 10000 tokens");
	    	assert.equal(two_ending_balance, two_starting_balance + amount, "second should have balance + 10000 tokens");
	    });
	});

	it("should increase allowance correctly", function() {
	    var token;

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[2];

	    var one_starting_balance;
	    var two_starting_balance;
	    var one_ending_balance;
	    var two_ending_balance;

	    var amount = 10000;

	    return MyDFSToken.deployed().then(function(instance) {
	    	token = instance;
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_starting_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_starting_balance = balance.toNumber();
	    	return token.increaseApproval(account_two, amount, {from: account_one});
	    }).then(function() {
	    	return token.allowance.call(account_one, account_two);
	    }).then(function(allowance) {
	    	assert(allowance.valueOf(), amount, "allowance is 10000 tokens");
	    	return token.transferFrom(account_one, account_two, amount, {from: account_two});
	    }).then(function() {
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_ending_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_ending_balance = balance.toNumber();

	    	assert.equal(one_ending_balance, one_starting_balance - amount, "first should have balance - 10000 tokens");
	    	assert.equal(two_ending_balance, two_starting_balance + amount, "second should have balance + 10000 tokens");
	    });
	});

	it("should denied overhead allowance correctly", function() {
	    var token;

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[2];

	    var one_starting_balance;
	    var two_starting_balance;
	    var one_ending_balance;
	    var two_ending_balance;

	    var amount = 10000;

	    return MyDFSToken.deployed().then(function(instance) {
	    	token = instance;
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_starting_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_starting_balance = balance.toNumber();
	    	return token.increaseApproval(account_two, amount, {from: account_one});
	    }).then(function() {
	    	return token.transferFrom(account_one, account_two, amount + 1, {from: account_two});
	    }).then(function() {
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_ending_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_ending_balance = balance.toNumber();

	    	assert.equal(one_ending_balance, one_starting_balance, "first should have balance without changes");
	    	assert.equal(two_ending_balance, two_starting_balance, "second should have balance without changes");
	    });
	});

	it("should decrease allowance correctly", function() {
	    var token;

	    // Get initial balances of first and second account.
	    var account_one = accounts[0];
	    var account_two = accounts[2];

	    var one_starting_balance;
	    var two_starting_balance;
	    var one_ending_balance;
	    var two_ending_balance;

	    var amount = 10000;

	    return MyDFSToken.deployed().then(function(instance) {
	    	token = instance;
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_starting_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_starting_balance = balance.toNumber();
	    	return token.decreaseApproval(account_two, amount, {from: account_one});
	    }).then(function() {
	    	return token.allowance.call(account_one, account_two);
	    }).then(function(allowance) {
	    	assert(allowance.valueOf(), amount, "allowance is 0 tokens");
	    	return token.transferFrom(account_one, account_two, amount, {from: account_two});
	    }).then(function() {
	    	return token.balanceOf.call(account_one);
	    }).then(function(balance) {
	    	one_ending_balance = balance.toNumber();
	    	return token.balanceOf.call(account_two);
	    }).then(function(balance) {
	    	two_ending_balance = balance.toNumber();

	    	assert.equal(one_ending_balance, one_starting_balance, "first should have balance without changes");
	    	assert.equal(two_ending_balance, two_starting_balance, "second should have balance without changes");
	    });
	});
});