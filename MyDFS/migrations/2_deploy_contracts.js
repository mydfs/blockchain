var MyDFSToken = artifacts.require("./MyDFSToken.sol");
var Dispatcher = artifacts.require("./Dispatcher.sol");
var GameLib = artifacts.require("./GameLogic.sol");
// var Game = artifacts.require("./MyDFSGame.sol");
// var Broker = artifacts.require("./BrokerManager.sol");
// var Stats = artifacts.require("./Stats.sol");

module.exports = function(deployer) {
  deployer.deploy(GameLib);
  deployer.deploy(MyDFSToken).then(function(){
    return deployer.deploy(Dispatcher, MyDFSToken.address);
  });
};