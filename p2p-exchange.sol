pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library StringLib {
  function compareTwoStrings(string memory s1, string memory s2)
    public
    pure
    returns (bool)
  {
    return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
  }
} 
contract Cur1 is ERC20{
     constructor() ERC20("Cur1Token", "CURR1"){
          _mint(msg.sender,10*10**18);
    }
}


contract Cur2 is ERC20{
     constructor() ERC20("Cur2Token", "CURR2"){
          _mint(msg.sender,10*10**18);
    }
}


contract P2PExchange {
    address payable public wallet;

    struct txSide{
        address payable wallet;
        ERC20    currency;
        uint256 qty;
        uint16 rate;
    }

    constructor(address payable _wallet){
        wallet = _wallet;

    }
   
   modifier costs (uint _amount) {
      require( msg.value > _amount,  "Not enough Ether provided as gas for the tx.");  
     _; 
      wallet.transfer(_amount);
   }

    // for simplicity lets assume the rate is always given as CURR1/CURR2 with 4 implied decimals
    function trade(txSide calldata buyer, txSide calldata seller ) public payable  costs(200 wei){

        require( StringLib.compareTwoStrings (buyer.currency.symbol(), "CURR1"), "buyer currency is not CURR1" );
        require(StringLib.compareTwoStrings(seller.currency.symbol() ,"CURR2"), "seller currency is not CURR2" );

        require( buyer.rate != 0, "buyer rate is zero");
        require( seller.rate != 0, "seller rate is zero");

        require( buyer.qty > 0, "buyer qty is zero");
        require( seller.qty > 0, "seller qty is zero");

        uint256 avgRate = ((buyer.rate + seller.rate ) /2)/4;

        require(buyer.currency.balanceOf(buyer.wallet) >= buyer.qty, "buyer doesnt have enough CURR1 tokens in its wallet");
        require(seller.currency.balanceOf(seller.wallet) >= seller.qty, "seller doesnt have enough CURR2 in its wallet");

        uint256 qtyNeeded4BuyerInCurr2=  buyer.qty * avgRate;
        uint256 qtyNeeded4SellerInCurr1 =  seller.qty / avgRate;

        if ( qtyNeeded4BuyerInCurr2 > seller.qty ) {
            qtyNeeded4BuyerInCurr2 = seller.qty;
            qtyNeeded4SellerInCurr1 =  qtyNeeded4BuyerInCurr2 / avgRate;
        }

        if ( qtyNeeded4SellerInCurr1 > buyer.qty ) {
            qtyNeeded4SellerInCurr1 = buyer.qty;
            qtyNeeded4BuyerInCurr2 =  qtyNeeded4SellerInCurr1 * avgRate;
        }

        buyer.currency.transferFrom(buyer.wallet, seller.wallet, qtyNeeded4SellerInCurr1);
        seller.currency.transferFrom(seller.wallet, buyer.wallet, qtyNeeded4BuyerInCurr2);
    }
}