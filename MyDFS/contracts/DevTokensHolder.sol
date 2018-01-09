pragma solidity ^0.4.16;


import "./GenericCrowdsale.sol";
import "./MyDFSToken.sol";


contract DevTokensHolder {

	address public owner;
    uint256 collectedTokens;
    GenericCrowdsale crowdsale;
    MyDFSToken token;

    event ClaimedTokens(address token, uint256 amount);
    event TokensWithdrawn(address holder, uint256 amount);

    modifier verified() { require(msg.sender == owner); _; }

    function DevTokensHolder(address _owner, address _contribution, address _snt) {
        owner = _owner;
        crowdsale = StatusContribution(_contribution);
        token = MiniMeToken(_snt);
    }


    /// @notice The Dev (Owner) will call this method to extract the tokens
    function collectTokens() public verified {
    	require(crowdsale.successed());
        uint256 balance = token.balanceOf(address(this));
        uint256 total = collectedTokens + balance;

        uint256 finalizedTime = contribution.deadline();
        require(finalizedTime > 0 && getTime() > finalizedTime);

        uint256 canExtract = total * (getTime() - finalizedTime) / months(12);
        canExtract = canExtract - collectedTokens;

        if (canExtract > balance) {
            canExtract = balance;
        }

        collectedTokens = collectedTokens + canExtract;
        assert(token.transfer(owner, canExtract));
        TokensWithdrawn(owner, canExtract);
    }

    function months(uint256 m) internal returns (uint256) {
        return m.mul(30 days);
    }

    function getTime() internal returns (uint256) {
        return now;
    }


    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public verified {
        require(_token != address(snt));
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