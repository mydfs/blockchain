pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/ERC223ReceivingContract.sol';

contract GenericCrowdsale is ERC223ReceivingContract {

    struct Deal {
        address user;
        uint256 amount;
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

    //адрес админа
    address admin;

    //остановка продаж в критичном случае
    bool emergencyPaused = false;

    //Продажи по стадиям (для распределения бонусов)
    mapping(uint8 => Deal[]) public stages;
    uint8[] public bonuses;
    uint8 max_stage = 0;
    uint8 get_bonus_stage = 0;
    uint8 get_bonus_num = 0;


    //событие на покупку токенов
    event TokenPurchased(address investor, uint sum, uint tokensCount);

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

    function buyTokens(address user, uint amount) internal {
    	require(amount < hardFundingGoal - amountRaised);
        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        require(tokenReward.transfer(user, count));
        balances[user] += amount;
        amountRaised += amount;
        storeStage(user, amount);
        TokenPurchased(msg.sender, amount, count);
    }

	function successed() internal view returns(bool) { }

    function tokenFallback(address from, uint value) { }

    function storeStage(address user, uint amount) internal {
        uint8 before_stage = uint8(10 * (amountRaised - amount) / hardFundingGoal);
        uint8 after_stage = uint8(10 * amountRaised / hardFundingGoal);
        
        if (before_stage != after_stage) {
            uint stage_amount = hardFundingGoal / 10;
            uint part1 = stage_amount - (amountRaised - amount) % stage_amount;
            stages[before_stage].push(Deal(user, part1));
            uint part2 = amount - part1;
            if (part2 > 0)
                storeStage(user, part2);
            else
                max_stage = before_stage;
        } else {
            stages[before_stage].push(Deal(user, amount));
            max_stage = before_stage;
        }
    }
}