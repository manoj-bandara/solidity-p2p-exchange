pragma solidity 0.5.1;

contract MyContract {
    mapping(address => uint256) public balances;
    uint256 totalIssued=0;
    address payable wallet;
     uint public creationTime = now;
    address owner;

    event Purchase(
        address indexed _buyer,
        uint256 _amount
    );

    constructor(address payable _wallet) public {
        wallet = _wallet;
        owner = msg.sender;
    }

    modifier onlyBy {
      require(tx.origin == owner, "Sender not authorized.");
      _;
   }
   modifier costs (uint _amount) {
      require( msg.value > _amount,  "Not enough Ether provided.");
     _;
      if (msg.value > _amount)
        msg.sender.transfer(msg.value -10 wei);
   }

   function changeOwner(address _newOwner) public onlyBy {
      owner = _newOwner;
   }
   modifier onlyAfter(uint _time) {
      require(
         now >= _time,
         "Function called too early."
      );
      _;
   }
   function disown() public onlyBy onlyAfter(creationTime + 6 weeks) {
      delete owner;
   }
  
   function forceOwnerChange(address _newOwner) public payable costs(100000 wei) {
      owner = _newOwner;
      if (uint(owner) & 0 == 1) return;        
   }

    function() external payable {
        buyToken();
    }

    function buyToken() public payable  costs(200 wei){
        balances[msg.sender] += 1;
        totalIssued++;
        wallet.transfer(msg.value);
        emit Purchase(msg.sender, 1);
    }
}
