pragma solidity ^0.5.0;
import "../contracts/SupplyChain.sol";

contract NotTheBuyer{
  function tryReceiveItem(address supplyChain, uint sku) public{
    SupplyChain(supplyChain).receiveItem(sku);
  }
}