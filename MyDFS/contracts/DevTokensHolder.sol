pragma solidity ^0.4.16;


import "./GenericCrowdsale.sol";
import "./MyDFSToken.sol";
import "./SafeMath.sol";


contract DevTokensHolder {
	using SafeMath for uint256;

	address public owner;
    uint256 collectedTokens;
    GenericCrowdsale crowdsale;
    MyDFSToken token;

    event ClaimedTokens(address token, uint256 amount);
    event TokensWithdrawn(address holder, uint256 amount);
    event Debug(uint256 amount);

    modifier verified() { require(msg.sender == owner); _; }

    function DevTokensHolder(address _crowdsale, address _token) {
        owner = msg.sender;
        crowdsale = GenericCrowdsale(_crowdsale);
        token = MyDFSToken(_token);
    }


    /// @notice The Dev (Owner) will call this method to extract the tokens
    function collectTokens() public verified {
    	require(crowdsale.successed());
        uint256 balance = token.balanceOf(address(this));
        uint256 total = collectedTokens.add(balance);

        uint256 finalizedTime = crowdsale.deadline();
        require(finalizedTime > 0 && getTime() > finalizedTime);

        uint256 canExtract = total.mul(getTime().sub(finalizedTime)).div(months(12));
        canExtract = canExtract.sub(collectedTokens);

        if (canExtract > balance) {
            canExtract = balance;
        }

        collectedTokens = collectedTokens.add(canExtract);
        assert(token.transfer(owner, canExtract));
        TokensWithdrawn(owner, canExtract);
    }

    function months(uint256 m) internal returns (uint256) {
        return m.mul(30 days);
    }

    function getTime() internal returns (uint256) {
        return now;
    }

	/**
     * Token fallback
     */
    function tokenFallback(address from, uint value) { }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public verified {
        require(_token != address(token));
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        MyDFSToken token = MyDFSToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, balance);
    }
}