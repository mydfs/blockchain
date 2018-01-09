pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/ERC223ReceivingContract.sol';

contract GenericCrowdsale is ERC223ReceivingContract {

    //Crowrdsale states
    enum State { Initialized, PreIco, Ico }

    struct Deal {
        address user;
        uint256 amount;
    }

    struct Discount {
        uint32 amount;
        uint16 value;
    }

    //ether trasfered to
    address public beneficiary;
    //Crowrdsale state
    State public state;
    //Hard goal in Wei
    uint public hardFundingGoal;
    //soft goal in Wei
    uint public softFundingGoal;
    //gathered Ether amount in Wei
    uint public amountRaised;
    //ICO/PreICO finish timestamp in seconds
    uint public deadline;
    //price for 1 token in Wei
    uint public price;
    //Token cantract
    Token public tokenReward;
    //Wei balances for refund if ICO failed
    mapping(address => uint256) public balances;

    //Admin address
    address admin;

    //Emergency stop sell
    bool emergencyPaused = false;
    //Soft cap reached
    bool softCapReached = false;
    
    //Disconts
    Discount[] public discounts;
    //Purchase stages for bonus distribution
    mapping(uint8 => Deal[]) public stages;
    //Bonus values for stages
    uint8[] public bonuses;
    //Last sell stage
    uint8 max_stage = 0;
    //Current bonus distribution stage
    uint8 get_bonus_stage = 0;
    //Current bonus distribution stage element
    uint8 get_bonus_num = 0;

    event TokenPurchased(address investor, uint sum, uint tokensCount, uint discountTokens);
    event PreIcoLimitReached(uint totalAmountRaised);
    event SoftGoalReached(uint totalAmountRaised);
    event HardGoalReached(uint totalAmountRaised);
    event Refund(address investor, uint sum);


    //Only admin access
    modifier verified() { require(msg.sender == admin); _; }
    //Sale is active
    modifier sellActive() { require(!emergencyPaused && state == State.PreIco && now < deadline && amountRaised < hardFundingGoal || state == State.Ico && now < deadline && amountRaised < hardFundingGoal); _; }
    //Soft cap not reached
    modifier goalNotReached() { require(state == State.Ico && amountRaised < softFundingGoal && now > deadline); _; }

    /**
     * Constrctor function
     */
    function GenericCrowdsale(
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward
    ) public {
        require(ifSuccessfulSendTo != address(0) 
            && addressOfTokenUsedAsReward != address(0));
        admin = msg.sender;
        beneficiary = ifSuccessfulSendTo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        initBonusStages();
        state = State.Initialized;
    }

    /**
     * Start PreICO
     */
    function PreICO(
        uint hardFundingGoalInEthers,
        uint durationInSeconds,
        uint szaboCostOfEachToken,
        uint32[] discountTokenAmount,
        uint16[] discountValues
    ) public {
        require(hardFundingGoalInEthers > 0
            && durationInSeconds > 0
            && szaboCostOfEachToken > 0
            && state == State.Initialized
            && discountTokenAmount.length == discountValues.length);

        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInSeconds * 1 seconds;
        price = szaboCostOfEachToken * 1 szabo;
        initDiscounts(discountTokenAmount, discountValues);
        state = State.PreIco;
    }

    /**
     * Start ICO
     */
    function ICO(
        uint softFundingGoalInEthers,
        uint hardFundingGoalInEthers,
        uint durationInSeconds,
        uint szaboCostOfEachToken,
        uint32[] discountTokenAmount,
        uint16[] discountValues
    ) external verified {
        require(softFundingGoalInEthers > 0
            && hardFundingGoalInEthers > 0
            && hardFundingGoalInEthers > softFundingGoalInEthers
            && durationInSeconds > 0
            && szaboCostOfEachToken > 0
            && state < State.Ico
            && discountTokenAmount.length == discountValues.length);

        softFundingGoal = softFundingGoalInEthers * 1 ether;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInSeconds * 1 seconds;
        price = szaboCostOfEachToken * 1 szabo;
        delete discounts;
        initDiscounts(discountTokenAmount, discountValues);
        state = State.Ico;
    }

    /**
     * Admin can pause token sell
     */
    function emergencyPause() external verified {
        emergencyPaused = true;
    }

    /**
     * Admin can unpause token sell
     */
    function emergencyUnpause() external verified {
        emergencyPaused = false;
    }

    /**
     * Admin can withdraw ether beneficiary address
     */
    function withdrawFunding() external verified {
        require((state == State.PreIco && now > deadline || successed()));
        beneficiary.transfer(this.balance);
    }

    /**
     * Distribute bonuses after ICO finished successfully 
     */
    function distributeBonuses() 
        external 
        verified 
        returns(bool) 
    {
        require(successed());

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

    /**
     * Claim refund ether in soft goal not reached 
     */
    function claimRefund() 
        external 
        goalNotReached 
    {
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

    /**
     * Payment transaction
     */
    function () 
        external 
        payable 
        sellActive 
    {
        require(msg.value > 0);
        uint amount = msg.value;
        if (amount > hardFundingGoal - amountRaised){
            uint availableAmount = hardFundingGoal - amountRaised;
            msg.sender.transfer(amount - availableAmount);
            amount = availableAmount;
        }

        buyTokens(msg.sender,  amount);
        checkGoals();
    }

    /**
     * Вifferent coins purchase
     */
    function foreignPurchase(address user, uint amount)
        external
        verified
        sellActive
    {
        buyTokens(user, amount);
        checkGoals();
    }

    /**
     * Transfer tokens to user
     */
    function buyTokens(
        address user,
        uint amount
    ) internal {
    	require(amount < hardFundingGoal - amountRaised);

        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        uint16 discount = getDiscountOf(count);
        uint discountBonus = discount * count / 100 + ((discount * count) % 100 > 0 ? 1 : 0);
        count += discountBonus;

        require(tokenReward.transfer(user, count));
        balances[user] += amount;
        amountRaised += amount;
        storeStage(user, amount);
        TokenPurchased(msg.sender, amount, count, discountBonus);
    }

    /**
     * ICO is finished successfully
     */
    function successed() 
        internal 
        view 
        returns(bool) 
    {
        return (state == State.Ico) && ((now >= deadline && amountRaised >= softFundingGoal) || amountRaised >= hardFundingGoal);
    }

    /**
     * Token fallback
     */
    function tokenFallback(address from, uint value) { }

    /**
     * Define bonus percents for different stages
     */
    function initBonusStages() internal {
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

    /**
     * Define distount percents for different token amounts
     */
    function initDiscounts(
        uint32[] discountTokenAmount,
        uint16[] discountValues
    ) internal {
        for (uint256 i = 0; i < discountTokenAmount.length; i++) {
            discounts.push(Discount(discountTokenAmount[i], discountValues[i]));
        }
    }

    /**
     * Get discount percent for number of tokens
     */
    function getDiscountOf(
        uint count
    ) 
        public
        constant
        returns (uint16)
    {
        if (discounts.length > 0)
            for (uint256 i = discounts.length - 1; i >= 0; i--) {
                if (count >= discounts[i].amount) {
                    return discounts[i].value;
                }
            }
        return 0;
    }

    /**
     * Store purchase stage for further receiving bonuses
     */
    function storeStage(
        address user, 
        uint amount
    ) internal {
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

    /**
     * Check ICO goals achievement
     */
    function checkGoals() internal {
        if (state == State.PreIco) {
            if (amountRaised >= hardFundingGoal) {
                PreIcoLimitReached(amountRaised);
            }
        } else {
            if (!softCapReached && amountRaised >= softFundingGoal){
                softCapReached = true;
                SoftGoalReached(amountRaised);
            }
            if (amountRaised >= hardFundingGoal){
                HardGoalReached(amountRaised);
            }
        }
    }
}