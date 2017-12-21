pragma solidity ^0.4.16;

import "./interface/Token.sol";

contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    function transfer(
        address to, 
        uint256 value
    )
        external
        returns (bool success) 
    {
        require(to != address(0));
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            Transfer(msg.sender, to, value);
            return true;
        } else { return false; }
    }

    function transferFrom(
        address from, 
        address to,
        uint256 value
    ) 
        external 
        returns (bool success)
    {
        require(from != address(0) && to != address(0));
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    function increaseApproval(
        address spender,
        uint256 value
    )
        external
        returns (bool success) 
    {
        allowed[msg.sender][spender] += value;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseApproval(
        address spender,
        uint256 value
    )
        external
        returns (bool success) 
    {
        require(spender != address(0));
        allowed[msg.sender][spender] -= value;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function balanceOf(address owner) external constant returns (uint256 balance) {
        return balances[owner];
    }

    function allowance(
        address owner, 
        address spender
    ) 
        external 
        constant 
        returns (uint256 remaining) 
    {
        return allowed[owner][spender];
    }
}