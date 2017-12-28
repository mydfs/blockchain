pragma solidity ^0.4.16;

import './interface/Token.sol';

contract GenericCrowdsale {
	//структура бонуса 100+eth -> 1%
    struct Bonus{
        uint32 amount;
        uint16 value;
    }

    //кому отправятся eth при достижении цели
    address public beneficiary;
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

    //событие на покупку токенов
    event TokenPurchase(address investor, uint sum, uint tokensCount, uint bonusTokens);

    //доступно только админу
    modifier verified() { require(msg.sender == admin); _; }

    //external
    function emergencyPause() external verified {
        emergencyPaused = true;
    }

    function emergencyUnpause() external verified {
        emergencyPaused = false;
    }

    function withdrawFunding() external {
        require(successed() && msg.sender == beneficiary);
        beneficiary.transfer(this.balance);
    }

    function getBonusOf(
        uint amount
    ) 
        public
        constant
        returns (uint16)
    {
        for (uint256 i = bonuses.length - 1; i >= 0; i--){
            if (amount >= bonuses[i].amount){
                return bonuses[i].value;
            }
        }
        return 0;
    }

    function buyTokens(uint amount) internal {
    	if (amount > hardFundingGoal - amountRaised){
            uint availableAmount = hardFundingGoal - amountRaised;
            msg.sender.transfer(amount - availableAmount);
            amount = availableAmount;
        }
        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        uint16 bonus = getBonusOf(count);
        uint bonusCount = bonus * count / 100 + ((bonus * count) % 100 > 0 ? 1 : 0);
        count += bonusCount;
        require(tokenReward.balanceOf(address(this)) >= count);
        balances[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, count);
        TokenPurchase(msg.sender, amount, count, bonusCount);
    }

    function checkGoals() internal { }
	function successed() internal view returns(bool) { }
}