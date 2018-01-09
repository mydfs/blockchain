pragma solidity ^0.4.16;

import "./interface/Token.sol";
import "./interface/ERC223ReceivingContract.sol";

contract StandardToken is Token {

    //user token balances
    mapping (address => uint256) balances;
    //token transer permissions
    mapping (address => mapping (address => uint256)) allowed;
    //tatal token number
    uint256 public totalSupply;

    /**
     * Token transfer from sender to to
     */
    function transfer(
        address to,
        uint256 value
    )
        external 
        returns (bool) 
    {
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            if (codeLength > 0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
                receiver.tokenFallback(msg.sender, value);
            }
            Transfer(msg.sender, to, value);
            return true;
        } else { return false; }
    }

    /**
     * Token transfer from from to to (permission needed)
     */
    function transferFrom(
        address from, 
        address to,
        uint256 value
    ) 
        external 
        returns (bool)
    {
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            if (codeLength > 0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
                receiver.tokenFallback(msg.sender, value);
            }
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    /**
     * Increase permission for transfer
     */
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

    /**
     * Decrease permission for transfer
     */
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

    /**
     * User token balance
     */
    function balanceOf(
        address owner
    ) 
        external 
        constant 
        returns (uint256) 
    {
        return balances[owner];
    }

    /**
     * User transfer permission
     */
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