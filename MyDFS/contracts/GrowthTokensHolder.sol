pragma solidity ^0.4.18;


import "./GenericCrowdsale.sol";
import "./MyDFSToken.sol";
import './Ownable.sol';
import "./SafeMath.sol";

contract GrowthTokensHolder is Ownable {
	using SafeMath for uint256;

    GenericCrowdsale crowdsale;
    MyDFSToken token;

    event ClaimedTokens(address token, uint256 amount);
    event TokensWithdrawn(address holder, uint256 amount);

    function GrowthTokensHolder(address _crowdsale, address _token, address _owner) public {
        crowdsale = GenericCrowdsale(_crowdsale);
        token = MyDFSToken(_token);
        owner = _owner;
    }

    function tokenFallback(
        address _from, 
        uint _value, 
        bytes _data
    ) 
        public 
        view 
    {
        require(_from == owner || _from == address(crowdsale));
    }

    /// @notice The Dev (Owner) will call this method to extract the tokens
    function collectTokens() public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0);

        uint256 finalizedTime = crowdsale.finishTime();
        require(finalizedTime > 0 && getTime() > finalizedTime.add(14 days));

        require(token.transfer(owner, balance));
        TokensWithdrawn(owner, balance);
    }

    function getTime() internal view returns (uint256) {
        return now;
    }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyOwner {
        require(_token != address(token));
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        token = MyDFSToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, balance);
    }
}