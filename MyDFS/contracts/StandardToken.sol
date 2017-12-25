pragma solidity ^0.4.16;

import "./interface/Token.sol";

contract StandardToken is Token {

    //балансы токенов всех пользователей 
    mapping (address => uint256) balances;
    //разрешения на перевод токенов юзера A юзеру B в количестве N
    mapping (address => mapping (address => uint256)) allowed;
    //общее количество выпущенных токенов
    uint256 public totalSupply;

    //перевод токенов с баланса msg.sender на баланс to в количесте value
    function transfer(
        address to, 
        uint256 value
    )
        external 
        returns (bool) 
    {
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            Transfer(msg.sender, to, value);
            return true;
        } else { return false; }
    }

    //перевод токенов юзера from юзеру to в количестве value(необходимо разрешение increaseApproval/decreaseApproval)
    function transferFrom(
        address from, 
        address to,
        uint256 value
    ) 
        external 
        returns (bool)
    {
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    //увеличить лимит на перевод с кошелька msg.sender для spender на значение value
    function increaseApproval(
        address spender,
        uint256 value
    )
        external
        returns (bool) 
    {
        allowed[msg.sender][spender] += value;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    //уменшить лимит на перевод с кошелька msg.sender для spender на значение value
    function decreaseApproval(
        address spender,
        uint256 value
    )
        external
        returns (bool) 
    {
        allowed[msg.sender][spender] -= value;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function balanceOf(address owner) external constant returns (uint256) {
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