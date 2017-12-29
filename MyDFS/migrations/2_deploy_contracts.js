var MyDFSToken = artifacts.require("./MyDFSToken.sol");
var Dispatcher = artifacts.require("./Dispatcher.sol");
var GameLib = artifacts.require("./GameLogic.sol");
var Game = artifacts.require("./Game.sol");
var Broker = artifacts.require("./BrokerManager.sol");
var Stats = artifacts.require("./UserStats.sol");

module.exports = function(deployer) {
	deployer.deploy(GameLib).then(function(){
    deployer.link(GameLib, [Game, Dispatcher]);
		return deployer.deploy(MyDFSToken).then(function(){
    		return deployer.deploy(Dispatcher, MyDFSToken.address).then(function(){
    			return deployer.deploy(Stats, Dispatcher.address).then(function(){
    				return deployer.deploy(Broker, MyDFSToken.address, Stats.address).then(function(){
    					return deployer.deploy(Game, MyDFSToken.address, Stats.address, Broker.address, "0x627306090abab3a6e1400e9345bc60c78a8bef57", Dispatcher.address, 5, 20, [50, 30, 20], [40, 30, 20, 10]);
                    });
    			});
    		});
  		});
  	});
};