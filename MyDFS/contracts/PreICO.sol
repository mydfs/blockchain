pragma solidity ^0.4.16;

import './interface/Token.sol';
import './GenericCrowdsale.sol';

contract PreICO is GenericCrowdsale {

    event HardGoalReached(uint totalAmountRaised);

    modifier active() { require(now < deadline && !emergencyPaused && amountRaised < hardFundingGoal); _; }

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function PreICO(
        address ifSuccessfulSendTo,
        uint hardFundingGoalInEthers,
        uint durationInMinutes,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward,
        uint32[] bonusesTokenAmount,
        uint16[] bonusesValues
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && hardFundingGoalInEthers > 0
            && durationInMinutes > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0)
            && bonusesTokenAmount.length == bonusesValues.length);
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        for (uint256 i = 0; i < bonusesTokenAmount.length; i++){
            bonuses[i] = Bonus(bonusesTokenAmount[i], bonusesValues[i]);
        }
    }

    function () external payable active {
        require(msg.value > 0);
        super.buyTokens(msg.sender,  msg.value);
        checkGoals();
    }

    function checkGoals() internal {
        if (amountRaised >= hardFundingGoal){
            HardGoalReached(amountRaised);
        } 
    }

    function successed() internal view returns(bool) {
        return now >= deadline;
    }
}
