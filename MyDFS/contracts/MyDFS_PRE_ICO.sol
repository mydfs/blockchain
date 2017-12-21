pragma solidity ^0.4.16;

import './interface/Token.sol';

contract MyDFSCrowdsale {
    
    struct Bonus{
        uint32 amount;
        uint16 value;
    }

    address public beneficiary;
    uint public hardFundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    Token public tokenReward;
    mapping(address => uint256) public balances;
    mapping(uint256 => Bonus) public bonuses;

    uint256 bonusesCount;
    address admin;

    bool emergencyPaused = false;

    event HardGoalReached(uint totalAmountRaised);
    event TokenPurchase(address investor, uint sum, uint tokensCount, uint bonusTokens);
    event Refund(address investor, uint sum);

    modifier active() { if (now < deadline && !emergencyPaused && amountRaised < hardFundingGoal) _; }
    modifier finished() { if (now >= deadline) _; }
    modifier verified() { if (msg.sender == admin) _; }

    //external

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function MyDFSCrowdsale(
        address ifSuccessfulSendTo,
        uint hardFundingGoalInEthers,
        uint durationInMinutes,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward,
        uint32[] bonusesEthAmount,
        uint16[] bonusesValues
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && hardFundingGoalInEthers > 0
            && durationInMinutes > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0)
            && bonusesEthAmount.length == bonusesValues.length);
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        bonusesCount = bonusesEthAmount.length;
        for (uint256 i = 0; i < bonusesCount; i++){
            bonuses[i] = Bonus(bonusesEthAmount[i], bonusesValues[i]);
        }
    }

    function () external payable active {
        uint amount = msg.value;
        if (amount > hardFundingGoal - amountRaised){
            uint availableAmount = hardFundingGoal - amountRaised;
            msg.sender.transfer(amount - availableAmount);
            amount = availableAmount;
        }
        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        uint16 bonus = getBonusOf(amount);
        uint bonusCount = bonus * count / 100 + ((bonus * count) % 100 > 0 ? 1 : 0);
        count += bonusCount;
        if (tokenReward.balanceOf(address(this)) >= count){
            balances[msg.sender] += amount;
            amountRaised += amount;
            tokenReward.transfer(msg.sender, count);
            TokenPurchase(msg.sender, amount, count, bonusCount);
        } else {
            revert();
        }
        if (amountRaised >= hardFundingGoal){
            HardGoalReached(amountRaised);
        } 
    }

    function emergencyPause() external verified {
        emergencyPaused = true;
    }

    function emergencyUnpause() external verified {
        emergencyPaused = false;
    }

    function withdrawFunding() external finished {
        if (msg.sender == beneficiary){
            beneficiary.transfer(this.balance);
        }
    }

    function getBonusOf(
        uint amount
    ) 
        public
        constant
        returns (uint16 value)
    {
        for (uint256 i = bonusesCount - 1; i >= 0; i--){
            if (amount >= bonuses[i].amount * 1 ether){
                return bonuses[i].value;
            }
        }
        return 0;
    }
}
