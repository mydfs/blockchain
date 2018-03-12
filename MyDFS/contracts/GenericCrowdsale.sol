pragma solidity ^0.4.18;

import './Ownable.sol';
import "./SafeMath.sol";
import "./interface/ERC223_interface.sol";
import "./DevTokensHolder.sol";
import "./AdvisorsTokensHolder.sol";

contract GenericCrowdsale is Ownable {
    using SafeMath for uint256;

    //Crowrdsale states
    enum State { Initialized, PreIco, PreIcoFinished, Ico, IcoFinished}

    struct Discount {
        uint256 amount;
        uint256 value;
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
    //ICO/PreICO start timestamp in seconds
    uint public started;
    //Crowdsale finish time
    uint public finishTime;
    //price for 1 token in Wei
    uint public price;
    //minimum purchase value in Wei
    uint public minPurchase;
    //Token cantract
    ERC223 public tokenReward;
    //Wei balances for refund if ICO failed
    mapping(address => uint256) public balances;

    //Emergency stop sell
    bool emergencyPaused = false;
    //Soft cap reached
    bool softCapReached = false;
    //dev holder
    DevTokensHolder public devTokensHolder;
    //advisors holder
    AdvisorsTokensHolder public advisorsTokensHolder;
    
    //Disconts
    Discount[] public discounts;

    //price overhead for next stages
    uint8[2] public preIcoTokenPrice = [70,75];
    //price overhead for next stages
    uint8[4] public icoTokenPrice = [100,120,125,130];

    event TokenPurchased(address investor, uint sum, uint tokensCount, uint discountTokens);
    event PreIcoLimitReached(uint totalAmountRaised);
    event SoftGoalReached(uint totalAmountRaised);
    event HardGoalReached(uint totalAmountRaised);
    event Debug(uint num);

    //Sale is active
    modifier sellActive() { 
        require(
            !emergencyPaused 
            && (state == State.PreIco || state == State.Ico)
            && amountRaised < hardFundingGoal
        );
    _; }
    //Soft cap not reached
    modifier goalNotReached() { require(state == State.IcoFinished && amountRaised < softFundingGoal); _; }

    /**
     * Constrctor function
     */
    function GenericCrowdsale(
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward
    ) public {
        require(ifSuccessfulSendTo != address(0) 
            && addressOfTokenUsedAsReward != address(0));
        beneficiary = ifSuccessfulSendTo;
        tokenReward = ERC223(addressOfTokenUsedAsReward);
        state = State.Initialized;
    }

    function tokenFallback(
        address _from, 
        uint _value, 
        bytes _data
    ) 
        public 
        view 
    {
        require(_from == owner);
    }

    /**
     * Start PreICO
     */
    function preIco(
        uint hardFundingGoalInEthers,
        uint minPurchaseInFinney,
        uint costOfEachToken,
        uint256[] discountEthers,
        uint256[] discountValues
    ) 
        external 
        onlyOwner 
    {
        require(hardFundingGoalInEthers > 0
            && costOfEachToken > 0
            && state == State.Initialized
            && discountEthers.length == discountValues.length);

        hardFundingGoal = hardFundingGoalInEthers.mul(1 ether);
        minPurchase = minPurchaseInFinney.mul(1 finney);
        price = costOfEachToken;
        initDiscounts(discountEthers, discountValues);
        state = State.PreIco;
        started = now;
    }

    /**
     * Start ICO
     */
    function ico(
        uint softFundingGoalInEthers,
        uint hardFundingGoalInEthers,
        uint minPurchaseInFinney,
        uint costOfEachToken,
        uint256[] discountEthers,
        uint256[] discountValues
    ) 
        external
        onlyOwner
    {
        require(softFundingGoalInEthers > 0
            && hardFundingGoalInEthers > 0
            && hardFundingGoalInEthers > softFundingGoalInEthers
            && costOfEachToken > 0
            && state < State.Ico
            && discountEthers.length == discountValues.length);

        softFundingGoal = softFundingGoalInEthers.mul(1 ether);
        hardFundingGoal = hardFundingGoalInEthers.mul(1 ether);
        minPurchase = minPurchaseInFinney.mul(1 finney);
        price = costOfEachToken;
        delete discounts;
        initDiscounts(discountEthers, discountValues);
        state = State.Ico;
        started = now;
    }

    /**
     * Finish ICO / PreICO
     */
    function finishSale() external onlyOwner {
        require(state == State.PreIco || state == State.Ico);
        
        if (state == State.PreIco)
            state = State.PreIcoFinished;
        else
            state = State.IcoFinished;
    }

    /**
     * Admin can pause token sell
     */
    function emergencyPause() external onlyOwner {
        emergencyPaused = true;
    }

    /**
     * Admin can unpause token sell
     */
    function emergencyUnpause() external onlyOwner {
        emergencyPaused = false;
    }

    /**
     * Transfer dev tokens to vesting wallet
     */
    function sendDevTokens() external onlyOwner returns(address) {
        require(successed());

        devTokensHolder = new DevTokensHolder(address(this), address(tokenReward), owner);
        tokenReward.transfer(address(devTokensHolder), 12500 * 1e9);
        return address(devTokensHolder);
    }

    /**
     * Transfer dev tokens to vesting wallet
     */
    function sendAdvisorsTokens() external onlyOwner returns(address) {
        require(successed());

        advisorsTokensHolder = new AdvisorsTokensHolder(address(this), address(tokenReward), owner);
        tokenReward.transfer(address(advisorsTokensHolder), 12500 * 1e9);
        return address(advisorsTokensHolder);
    }

    /**
     * Admin can withdraw ether beneficiary address
     */
    function withdrawFunding() external onlyOwner {
        require((state == State.PreIco || successed()));
        beneficiary.transfer(this.balance);
    }

    /**
     * Different coins purchase
     */
    function foreignPurchase(address user, uint256 amount)
        external
        onlyOwner
        sellActive
    {
        buyTokens(user, amount);
        checkGoals();
    }

    /**
     * Claim refund ether in soft goal not reached 
     */
    function claimRefund() 
        external 
        goalNotReached 
    {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        if (amount > 0){
            if (!msg.sender.send(amount)) {
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
        require(msg.value >= minPurchase);
        uint amount = msg.value;
        if (amount > hardFundingGoal.sub(amountRaised)) {
            uint availableAmount = hardFundingGoal.sub(amountRaised);
            msg.sender.transfer(amount.sub(availableAmount));
            amount = availableAmount;
        }

        buyTokens(msg.sender,  amount);
        checkGoals();
    }

    /**
     * Transfer tokens to user
     */
    function buyTokens(
        address user,
        uint256 amount
    ) internal {
    	require(amount <= hardFundingGoal.sub(amountRaised));

        uint256 passedSeconds = getTime().sub(started);
        uint256 week = 0;
        if (passedSeconds >= 604800){
            week = passedSeconds.div(604800);
        }
        Debug(week);

        uint256 tokenPrice;
        if (state == State.Ico){
            uint256 cup = amountRaised.mul(4).div(hardFundingGoal);
            if (cup > week)
                week = cup;
            if (week >= 4)
                 week = 3;
            tokenPrice = price.mul(icoTokenPrice[week]).div(100);
        } else {
            if (week >= 2)
                 week = 1;
            tokenPrice = price.mul(preIcoTokenPrice[week]).div(100);
        }

        Debug(tokenPrice);

        uint256 count = amount.div(tokenPrice);
        uint256 discount = getDiscountOf(amount);
        uint256 discountBonus = discount.mul(count).div(100);
        count = count.add(discountBonus);

        require(tokenReward.transfer(user, count));
        balances[user] = balances[user].add(amount);
        amountRaised = amountRaised.add(amount);
        TokenPurchased(user, amount, count, discountBonus);
    }

    /**
     * ICO is finished successfully
     */
    function successed() 
        public 
        view 
        returns(bool) 
    {
        return state == State.IcoFinished && amountRaised >= softFundingGoal;
    }

    /**
     * Define distount percents for different token amounts
     */
    function initDiscounts(
        uint256[] discountEthers,
        uint256[] discountValues
    ) internal {
        for (uint256 i = 0; i < discountEthers.length; i++) {
            discounts.push(Discount(discountEthers[i].mul(1 ether), discountValues[i]));
        }
    }

    /**
     * Get discount percent for number of tokens
     */
    function getDiscountOf(
        uint256 _amount
    )
        public
        view
        returns (uint256)
    {
        if (discounts.length > 0)
            for (uint256 i = 0; i < discounts.length; i++) {
                if (_amount >= discounts[i].amount) {
                    return discounts[i].value;
                }
            }
        return 0;
    }

    /**
     * Check ICO goals achievement
     */
    function checkGoals() internal {
        if (state == State.PreIco) {
            if (amountRaised >= hardFundingGoal) {
                PreIcoLimitReached(amountRaised);
                state = State.PreIcoFinished;
            }
        } else {
            if (!softCapReached && amountRaised >= softFundingGoal){
                softCapReached = true;
                SoftGoalReached(amountRaised);
            }
            if (amountRaised >= hardFundingGoal) {
                finishTime = now;
                HardGoalReached(amountRaised);
                state = State.IcoFinished;
            }
        }
    }

    function getTime() internal view returns (uint) {
        return now;
    }
}