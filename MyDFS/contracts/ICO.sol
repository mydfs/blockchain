pragma solidity ^0.4.16;

import './interface/Token.sol';
import './GenericCrowdsale.sol';

contract ICO is GenericCrowdsale {
    
    //легкая цель, например 10 ether
    uint public softFundingGoal;

    bool softCapReached = false;

    //событие о том, что мы достигли soft cap
    event SoftGoalReached(uint totalAmountRaised);
    //событие о том, что мы достигли hard cap
    event HardGoalReached(uint totalAmountRaised);
    //событие если вернули эфир
    event Refund(address investor, uint sum);

    //ICO активно
    modifier active() { require(now < deadline && !emergencyPaused && amountRaised < hardFundingGoal); _; }
    //если не достигли soft cap
    modifier goalNotReached() { require(now >= deadline && amountRaised < softFundingGoal); _; }

    //external

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function ICO(
        address ifSuccessfulSendTo,
        uint softFundingGoalInEthers,
        uint hardFundingGoalInEthers,
        uint durationInSeconds,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward,
        uint32[] bonusesTokenAmount,
        uint16[] bonusesValues
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && softFundingGoalInEthers > 0
            && hardFundingGoalInEthers > 0
            && hardFundingGoalInEthers > softFundingGoalInEthers
            && durationInSeconds > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0)
            && bonusesTokenAmount.length == bonusesValues.length);
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        softFundingGoal = softFundingGoalInEthers * 1 ether;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInSeconds * 1 seconds;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        for (uint256 i = 0; i < bonusesTokenAmount.length; i++){
            bonuses.push(Bonus(bonusesTokenAmount[i], bonusesValues[i]));
        }
    }

    function () external payable active {
        require(msg.value > 0);
        super.buyTokens(msg.sender,  msg.value);
        checkGoals();
    }

    function claimRefund() external goalNotReached {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        if (amount > 0){
            if (msg.sender.send(amount)) {
                Refund(msg.sender, amount);
            } else {
                balances[msg.sender] = amount;
            }
        }
    }
    
    function checkGoals() internal {
        if (!softCapReached && amountRaised >= softFundingGoal){
            softCapReached = true;
            SoftGoalReached(amountRaised);
        }
        if (amountRaised >= hardFundingGoal){
            HardGoalReached(amountRaised);
        } 
    }

    function successed() internal view returns(bool) {
        return (now >= deadline && amountRaised >= softFundingGoal) || amountRaised >= hardFundingGoal;
    }
}
