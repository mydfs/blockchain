var Migrations = artifacts.require("./Migrations.sol");
var MyDFSToken = artifacts.require("./MyDFSToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MyDFSToken);
};
