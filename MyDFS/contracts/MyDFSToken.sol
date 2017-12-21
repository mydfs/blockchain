pragma solidity ^0.4.16;

import './StandardToken.sol';

contract MyDFSToken is StandardToken {

    string public constant name = "MyDFS Token";                  
    uint8 public constant decimals = 0;               
    string public constant symbol = "MyDFS";             
    string public version = 'H1.0';    

    function () external {
        revert();
    } 

    function MyDFSToken() public {
        balances[msg.sender] = 100000;              
        totalSupply = 100000;                                        
    }
}