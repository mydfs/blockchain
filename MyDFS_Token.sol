pragma solidity ^0.4.16;

contract Token {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}

contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    function transfer(address to, uint256 value) public returns (bool success) {
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            Transfer(msg.sender, to, value);
            return true;
        } else { return false; }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    function balanceOf(address owner) public constant returns (uint256 balance) {
        return balances[owner];
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public constant returns (uint256 remaining) {
      return allowed[owner][spender];
    }
}


contract GameToken is StandardToken {

    function () public {
        revert();
    }

    string public name;                  
    uint8 public decimals;               
    string public symbol;             
    string public version = 'H1.0';     

    function GameToken(
        ) public {
        balances[msg.sender] = 100000;              
        totalSupply = 100000;                        
        name = "MyDFS Token";                                  
        decimals = 0;                           
        symbol = "MyDFS";                 
    }
}