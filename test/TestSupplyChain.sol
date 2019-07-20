pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./NotTheSeller.sol";
import "./NotTheBuyer.sol";
import "./ThrowProxy.sol";

contract TestSupplyChain {

    uint public initialBalance = 1000000000;
    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    function() external payable { }
    // buyItem

    // test for failure if user does not send enough funds
    function testBuyItemFailureIfNotEnoughFunds() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain(supplyChainAddress).addItem("book", 1000);

      //This seems clearer than throw proxy.
      //If using Throw proxy 
      //when SupplyChain contract refund excess value back to buyer, the whole call chain will be
      //reverted due to 2300 gas limit of fallback function.
      (bool r, ) = supplyChainAddress.call.value(800)(abi.encodeWithSignature("buyItem(uint256)",0));
      Assert.isFalse(r, "Should revert if funds not enough");
    }
    //test for purchasing an item that is not for Sale
    function testBuyItemFailureIfNotForSale() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain supplyChain = SupplyChain(supplyChainAddress);
      supplyChain.addItem("Toy", 2000);
      uint sku = supplyChain.skuCount() - 1;
      supplyChain.buyItem.value(2000)(sku);
      //Throw Proxy
      ThrowProxy throwProxy = new ThrowProxy(supplyChainAddress);
      SupplyChain(address(throwProxy)).buyItem.value(2000)(0);
      bool r = throwProxy.execute();
      // (bool r, ) = supplyChainAddress.call.value(2000)(abi.encodeWithSignature("buyItem(uint256)",sku));
      Assert.isFalse(r, "Should revert if not for sale");
    }
    // shipItem

    // test for calls that are made by not the seller
    function testshipItemFailureIfNotTheseller() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain supplyChain = SupplyChain(supplyChainAddress);
      supplyChain.addItem("Food", 500);
      uint sku = supplyChain.skuCount() - 1;
      supplyChain.buyItem.value(500)(sku);
      NotTheSeller notTheSeller = new NotTheSeller();
      (bool r, ) = address(notTheSeller).call(abi.encodeWithSignature("tryShip(address,uint256)", address(supplyChainAddress), sku));
      Assert.isFalse(r, "Should revert if not the seller");
    }
    //test for trying to ship an item that is not marked Sold
    function testshipItemFailureIfNotSold() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain supplyChain = SupplyChain(supplyChainAddress);
      supplyChain.addItem("Food", 500);
      uint sku = supplyChain.skuCount() - 1;
      (bool r, ) = supplyChainAddress.call(abi.encodeWithSignature("shipItem(uint256)", sku));
      Assert.isFalse(r, "Should revert if not sold");
    }
    // receiveItem

    // test calling the function from an address that is not the buyer
    function testshipItemFailureIfNotBuyer() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain supplyChain = SupplyChain(supplyChainAddress);
      supplyChain.addItem("clothes", 250);
      uint sku = supplyChain.skuCount() - 1;
      supplyChain.buyItem.value(250)(sku);
      supplyChain.shipItem(sku);
      NotTheBuyer notTheBuyer = new NotTheBuyer();
      (bool r, ) = address(notTheBuyer).call(abi.encodeWithSignature("tryReceiveItem(address,uint256)", address(supplyChainAddress), sku));
      Assert.isFalse(r, "Should revert if not the buyer");
    }
    // test calling the function on an item not marked Shipped
    function testshipItemFailureIfNotShipped() public {
      address payable supplyChainAddress = DeployedAddresses.SupplyChain();
      SupplyChain supplyChain = SupplyChain(supplyChainAddress);
      supplyChain.addItem("clothes", 250);
      uint sku = supplyChain.skuCount() - 1;
      supplyChain.buyItem.value(250)(sku);
      (bool r, ) = supplyChainAddress.call(abi.encodeWithSignature("receiveItem(uint256)", sku));
      Assert.isFalse(r, "Should revert if not Shipped");
    }
}


