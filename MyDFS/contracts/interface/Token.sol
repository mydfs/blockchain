pragma solidity ^0.4.18;

interface Token {

    function transfer(address to, uint256 value) public returns (bool success);

    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function increaseApproval(address spender, uint256 value) public returns (bool success);
    function decreaseApproval(address spender, uint256 value) public returns (bool success);

    function balanceOf(address owner) public constant returns (uint256 balance);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Debug(uint value);
} 
