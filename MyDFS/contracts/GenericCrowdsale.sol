pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/ERC223ReceivingContract.sol';

contract GenericCrowdsale is ERC223ReceivingContract {
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

    event Debug(uint value);

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
        uint count
    ) 
        public
        constant
        returns (uint16)
    {
        for (uint256 i = bonuses.length - 1; i >= 0; i--){
            if (count >= bonuses[i].amount){
                return bonuses[i].value;
            }
        }
        return 0;
    }

    function buyTokens(address user, uint amount) internal {
    	require(amount < hardFundingGoal - amountRaised);
        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        uint16 bonus = getBonusOf(count);
        uint bonusCount = bonus * count / 100 + ((bonus * count) % 100 > 0 ? 1 : 0);
        count += bonusCount;
        require(tokenReward.transfer(user, count));
        balances[user] += amount;
        amountRaised += amount;
        TokenPurchase(msg.sender, amount, count, bonusCount);
    }

	function successed() internal view returns(bool) { }

    function tokenFallback(address from, uint value) { }
}