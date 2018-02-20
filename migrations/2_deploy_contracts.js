const Wrestling = artifacts.require("./Escrow.sol")

module.exports = function(deployer) {
	deployer.deploy(Escrow);
};