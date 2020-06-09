pragma solidity 0.6.7;

contract MultisigWallet
{
	event Confirmation(address indexed sender, uint indexed transactionId);
    event withdraw(address indexed to,uint value);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    uint constant public MAX_OWNER = 5;

    mapping(uint=>Transaction) public transactions;
    mapping(uint=>mapping(address=>bool)) public confirmations;
    mapping(address=>bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction
    {
    	address destination;
    	uint value;
    	bool executed;
    }

    modifier ownerDoesnotExist(address owner)
    {
    	require(!isOwner[owner]);
    	_;
    }
    modifier ownerExists(address owner)
    {
    	require(isOwner[owner],"ownerExists");
    	_;
    }
    modifier transactionExists(uint transactionId)
    {
    	require(transactions[transactionId].destination != address(0),"transactionExists");
    	_;
    }
    modifier confirmed(uint transactionId,address owner)
    {
    	require(confirmations[transactionId][owner]);
    	_;
    }
    modifier notconfirmed(uint transactionId,address owner)
    {
    	require(!confirmations[transactionId][owner],"notconfirmed");
    	_;
    }
    modifier notExecuted(uint transactionId)
    {
    	require(!transactions[transactionId].executed);
    	_;
    }
    modifier notNull(address _address)
    {
    	require(_address != address(0));
    	_;
    }
    modifier validRequirement(uint ownerCount,uint _require)
    {
    	require(ownerCount <= MAX_OWNER && _require <= ownerCount && _require !=0 && ownerCount !=0);
    	_;
    }
    function deposit() public payable
    {
    	if(msg.value>0)
    	{
    	  emit	Deposit(msg.sender,msg.value);
    	}
    }

    constructor(address[] memory _owners,uint _required) public
    validRequirement(_owners.length,_required)
    {
    	for(uint i=0;i<_owners.length;i++)
    	{
    		require(!isOwner[_owners[i]] && _owners[i] != address(0));
    		isOwner[_owners[i]] =true;
    	}
    	owners = _owners;
    	required = _required;
    }

    function submitTransaction(address destination,uint value) public returns(uint transactionId)
    {
      transactionId = addTransaction(destination,value);
      confirmTransaction(transactionId);

    }

    function confirmTransaction(uint transactionId) public ownerExists(msg.sender) transactionExists(transactionId) notconfirmed(transactionId,msg.sender)
    {
    	confirmations[transactionId][msg.sender] = true;
    	Confirmation(msg.sender,transactionId);
    	executeTransation(transactionId);
    }

    function addTransaction(address destination,uint value) internal notNull(destination) returns(uint transactionId) 
    {
        transactionId = transactionCount;
    	transactions[transactionId] = Transaction(destination,value,false);
    	transactionCount +=1;
    	Submission(transactionId);
    }

    function executeTransation(uint transactionId) public ownerExists(msg.sender) confirmed(transactionId,msg.sender) notExecuted(transactionId)
    {
    	if(isConfirmed(transactionId))
    	{
    		transactions[transactionId].executed = true;
    		Execution(transactionId);
    		payable(transactions[transactionId].destination).transfer(address(this).balance);

    	}
    	else
    	{
    		ExecutionFailure(transactionId);
    		transactions[transactionId].executed = false;
    	}
    }

    function isConfirmed(uint transactionId)public view returns(bool)
    {
    	uint count =0;
    	for(uint i=0;i<owners.length;i++)
    	{
    		if(confirmations[transactionId][owners[i]])
    		{
    			count +=1;
    		}
    		if(count == required)
    		{
    			return true;
    		}
    	}
    }

    function getConfirmationCount(uint transactionId) public view returns(uint count)
    {
    	for(uint i=0;i<owners.length;i++)
    	{
    		if(confirmations[transactionId][owners[i]])
    		{
    			count+=1;
    		}
    	}
    }

    function checkBalanceThisWallet() public view returns(uint)
    {
    	return address(this).balance;
    }



    
}