pragma solidity ^0.5.0;

// Proxy contract for testing throws
contract ThrowProxy {
  address payable public target;
  bytes data;

  constructor(address payable _target) public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() external payable {
    //If the target function ThrowProxy forwarded to refunds
    //excess value back to ThrowProxy using transfer().
    //line below will cause revert due to 2300 gas limit of transfer()
    data = msg.data;
  }

  function execute() public returns (bool) {
    (bool succeeded, ) = target.call.value(address(this).balance)(data);
    return succeeded;
  }
}