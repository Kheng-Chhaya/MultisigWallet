const MultisigWallet = artifacts.require("MultisigWallet.sol");

module.exports = function(deployer) {
	const address = ["0x1ddc388B01ea5650D88166194A78f36C9C1aC7F6","0x2321a67b4ceA422B77Ab73896e3c0eff2C596EEc","0xC55248Fa4252d4d5B434A535Cc0FFE85ad942d83"];
  deployer.deploy(MultisigWallet,address,2);
};
