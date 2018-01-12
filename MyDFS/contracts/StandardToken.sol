pragma solidity ^0.4.18;

import "./interface/Token.sol";
import "./interface/ERC223ReceivingContract.sol";
import "./SafeMath.sol";

contract StandardToken is Token {
    using SafeMath for uint256;

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
        public 
        returns (bool) 
    {
        bytes memory empty;
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(value);
            balances[to] = balances[to].add(value);
            if (codeLength > 0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
                receiver.tokenFallback(msg.sender, value, empty);
            }
            Transfer(msg.sender, to, value, empty);
            return true;
        } else { return false; }
    }


    /**
     * Token transfer from sender to to
     */
    function transfer(
        address to,
        uint256 value,
        bytes _data
    )
        public 
        returns (bool) 
    {
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(value);
            balances[to] = balances[to].add(value);
            if (codeLength > 0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
                receiver.tokenFallback(msg.sender, value, _data);
            }
            Transfer(msg.sender, to, value, _data);
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
        public 
        returns (bool)
    {
        bytes memory empty;
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] = balances[to].add(value);
            balances[from] = balances[from].sub(value);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
            if (codeLength > 0) {
                ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
                receiver.tokenFallback(msg.sender, value, empty);
            }
            Transfer(from, to, value, empty);
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
        public
        returns (bool) 
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
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
        public
        returns (bool) 
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
     * User token balance
     */
    function balanceOf(
        address owner
    ) 
        public 
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
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[owner][spender];
    }
}