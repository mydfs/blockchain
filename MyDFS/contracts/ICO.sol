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
        address addressOfTokenUsedAsReward
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && softFundingGoalInEthers > 0
            && hardFundingGoalInEthers > 0
            && hardFundingGoalInEthers > softFundingGoalInEthers
            && durationInSeconds > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0));
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        softFundingGoal = softFundingGoalInEthers * 1 ether;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInSeconds * 1 seconds;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);

        if (bonuses.length < 1) {
            bonuses.push(1);
            bonuses.push(2);
            bonuses.push(3);
            bonuses.push(5);
            bonuses.push(8);
            bonuses.push(13);
            bonuses.push(21);
            bonuses.push(34);
            bonuses.push(55);
        }
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

    function distributeBonuses() external returns(bool) {
        require(successed() && msg.sender == beneficiary);

        if (get_bonus_num >= stages[get_bonus_stage].length) {
            get_bonus_stage += 1;
            if (get_bonus_stage >= max_stage)
                return false;
            get_bonus_num = 0;
        }

        uint8 stage_bonus_percent = bonuses[max_stage - get_bonus_stage - 1];
        uint token_bonus = (stages[get_bonus_stage][get_bonus_num].amount * stage_bonus_percent / 100) / price;
        tokenReward.transfer(stages[get_bonus_stage][get_bonus_num].user, token_bonus);
        get_bonus_num += 1;
        return true;
    }
}
