pragma solidity ^0.8.0;

/* @Audit: Import SafeMath */
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Crowdsale {
   using SafeMath for uint256;
   
   /* See description (1) below the smart contract */
   address public owner; // the owner of the contract
   
   /* @Audit payable address */
   address payable public escrow; // wallet to collect raised ETH
   
   /* @Audit: solidity already instantiates variables to 0, lost resource */
   /* @Old: uint256 public savedBalance = 0; // Total amount raised in ETH */
   uint256 public savedBalance; // Total amount raised in ETH 
   
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   /* @Audit: Need a constructor here for a real initialization */
   /* @Old: function Crowdsale(address _escrow) public { */
   constructor(address payable _escrow) public {
       /* @Audit: Use msg.sender instead of tx.origin or use Ownable pattern */
       /* @ Old: owner = tx.origin; */
       owner = msg.sender;
       
       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
   function deposit() payable public {
       /* @Audit: A minimum value would be appreciated with a require() */
       
       balances[msg.sender] = balances[msg.sender].add(msg.value);
       savedBalance = savedBalance.add(msg.value);
       
       /* @Audit: Use transfer() instead of send() */
       /* @Old: escrow.send(msg.value); */
       escrow.transfer(msg.value);
   }
  
   // refund investisor
   function withdrawPayments() payable public {
       address payee = msg.sender;
       uint256 payment = balances[payee];
       
       /* @Audit: Do before the transfer */
       savedBalance = savedBalance.sub(payment);
       balances[payee] = 0;
       
       /* @Audit: use transfer() instead of send() */
       /* @Old: payee.send(payment); */
       /* @Info: Can't get back our money see description (2) below the smart contract */
       payable(payee).transfer(payment);
       
       /* @Old:
       savedBalance = savedBalance.sub(payment);
       balances[payee] = 0;
       */
   }
   /*
   function getBalance() public view returns(uint) {
       return address(this).balance;
   }*/
}

/** @Audit:
 * 
 * Advertise
 * 
 * 1) <owner> variable is never used
 * 2) The user cannot recover his funds because they are sent on a smart contract whose structure is not known. 
 * It should be possible to recover the funds via a function call from the wallet address.
**/
