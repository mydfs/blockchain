pragma solidity ^0.4.16;

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value);
}