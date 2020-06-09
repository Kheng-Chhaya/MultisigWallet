const MultsigWallet = artifacts.require("MultisigWallet.sol");

contract("MultsigWallet",(accounts)=>{

it("testing the deposit function",()=>{
	var instance;
	return MultsigWallet.deployed().then((ins)=>{
		instance = ins;
		return instance.deposit({from:accounts[0],value:1000000000000000000})
	}).then((tx)=>{
		assert.equal(tx.logs.length,1,"Deposit should be triggered");
		assert.equal(tx.logs[0].event,"Deposit","Deposit is be triggered");
		assert.equal(tx.logs[0].args.sender,accounts[0],"accounts[0] should be the sender");
		return web3.eth.getBalance(instance.address);
	}).then((balance)=>{
		console.log(web3.utils.fromWei(balance),"ether");
		return instance.submitTransaction(accounts[0],1);
	}).then((tx)=>{
		return instance.confirmTransaction(0,{from:accounts[1]})
	}).then((tx)=>{
		return instance.getConfirmationCount(0);
	}).then((getConfirmationCount)=>{
		assert.equal(getConfirmationCount.valueOf(),2,"Not equal 2")
		return web3.eth.getBalance(instance.address)
	}).then((balance)=>{
		console.log(web3.utils.fromWei(balance),"ether","balance after transfered");
	})

})













})