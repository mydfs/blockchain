pragma solidity ^0.4.18;

import './StandardToken.sol';

contract MyDFSToken is StandardToken {

    string public name = "MyDFS Token";
    uint8 public decimals = 6;
    string public symbol = "MyDFS";
    string public version = 'H1.0';
    uint256 public totalSupply;

    function () external {
        revert();
    } 

    function MyDFSToken() public {
        totalSupply = 1 * 1e15;
        balances[msg.sender] = totalSupply;
    }

    // Function to access name of token .
    function name() public view returns (string _name) {
        return name;
    }
    // Function to access symbol of token .
    function symbol() public view returns (string _symbol) {
        return symbol;
    }
    // Function to access decimals of token .
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }
    // Function to access total supply of tokens .
    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }
}