pragma solidity ^0.5.0;
import "../contracts/SupplyChain.sol";

contract NotTheSeller{
  function tryShip(address supplyChain, uint sku) public{
    SupplyChain(supplyChain).shipItem(sku);
  }
}