pragma solidity ^0.4.16;

import './interface/Token.sol';

contract MyDFSICO {
    
    //структура бонуса 100+eth -> 1%
    struct Bonus{
        uint32 amount;
        uint16 value;
    }

    //кому отправятся eth при достижении цели
    address public beneficiary;
    //легкая цель, например 10 ether
    uint public softFundingGoal;
    //сложная цель, например 50 ether
    uint public hardFundingGoal;
    //сколько уже собрали
    uint public amountRaised;
    //время завершения - timestamp
    uint public deadline;
    //цена за 1 токен
    uint public price;
    //контракт токена, который мы продаем
    Token public tokenReward;
    //балансы эфира инвесторов, который они перевели
    mapping(address => uint256) public balances;
    //бонусы
    Bonus[] public bonuses;

    //адрес админа
    address admin;

    //остановка продаж в критичном случае
    bool emergencyPaused = false;

    bool softCapReached = false;

    //событие о том, что мы достигли soft cap
    event SoftGoalReached(uint totalAmountRaised);
    //событие о том, что мы достигли hard cap
    event HardGoalReached(uint totalAmountRaised);
    //событие на покупку токенов
    event TokenPurchase(address investor, uint sum, uint tokensCount, uint bonusTokens);
    //событие если вернули эфир
    event Refund(address investor, uint sum);

    //ICO активно
    modifier active() { if (now < deadline && !emergencyPaused && amountRaised < hardFundingGoal) _; }
    //если не достигли soft cap
    modifier goalNotReached() { if (now >= deadline && amountRaised < softFundingGoal) _; }
    //что ICO успешно завершилось
    modifier successed() { if ((now >= deadline && amountRaised >= softFundingGoal) || amountRaised >= hardFundingGoal) _; }
    //доступно только админу
    modifier verified() { if (msg.sender == admin) _; }

    //external

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function MyDFSICO(
        address ifSuccessfulSendTo,
        uint softFundingGoalInEthers,
        uint hardFundingGoalInEthers,
        uint durationInMinutes,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward,
        uint32[] bonusesTokenAmount,
        uint16[] bonusesValues
    ) public {
        require(ifSuccessfulSendTo != address(0)
            && softFundingGoalInEthers > 0
            && hardFundingGoalInEthers > 0
            && hardFundingGoalInEthers > softFundingGoalInEthers
            && durationInMinutes > 0
            && szaboCostOfEachToken > 0
            && addressOfTokenUsedAsReward != address(0)
            && bonusesTokenAmount.length == bonusesValues.length);
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        softFundingGoal = softFundingGoalInEthers * 1 ether;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        for (uint256 i = 0; i < bonusesTokenAmount.length; i++){
            bonuses.push(Bonus(bonusesTokenAmount[i], bonusesValues[i]));
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
        uint16 bonus = getBonusOf(count);
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
        if (!softCapReached && amountRaised >= softFundingGoal){
            softCapReached = true;
            SoftGoalReached(amountRaised);
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

    function withdrawFunding() external successed {
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
        for (uint256 i = bonuses.length - 1; i >= 0; i--){
            if (amount >= bonuses[i].amount){
                return bonuses[i].value;
            }
        }
        return 0;
    }
}
