pragma solidity ^0.4.16;

interface Token {

    function transfer(address to, uint256 value) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function increaseApproval(address spender, uint256 value) external returns (bool success);
    function decreaseApproval(address spender, uint256 value) external returns (bool success);

    function balanceOf(address owner) external constant returns (uint256 balance);
    function allowance(address owner, address spender) external constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

} 
