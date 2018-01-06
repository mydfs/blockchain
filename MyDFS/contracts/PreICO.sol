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
        uint durationInSeconds,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && hardFundingGoalInEthers > 0
            && durationInSeconds > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0));
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInSeconds * 1 seconds;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
    }

    function () external payable active {
        require(msg.value > 0);
        uint amount = msg.value;
        if (amount > hardFundingGoal - amountRaised){
            uint availableAmount = hardFundingGoal - amountRaised;
            msg.sender.transfer(amount - availableAmount);
            amount = availableAmount;
        }

        super.buyTokens(msg.sender,  amount);
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
