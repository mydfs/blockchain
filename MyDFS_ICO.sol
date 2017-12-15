pragma solidity ^0.4.16;

interface Token {
    function transfer(address to, uint256 value) public returns (bool success);
    function balanceOf(address owner) public constant returns (uint256 balance);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);
} 

contract MyDFSCrowdsale {
    
    struct Bonus{
        uint32 amount;
        uint16 value;
    }

    address public beneficiary;
    uint public softFundingGoal;
    uint public hardFundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    Token public tokenReward;
    address tokenHandlerAddress;
    mapping(address => uint256) public balance;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    mapping(uint256 => Bonus) public bonuses;
    uint256 bonusesCount;

    event SoftGoalReached(address recipient, uint totalAmountRaised);
    event HardGoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function MyDFSCrowdsale(
        address ifSuccessfulSendTo,
        uint softFundingGoalInEthers,
        uint hardFundingGoalInEthers,
        uint durationInMinutes,
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward,
        address tokenHandler,
        uint32[] bonusesCounts,
        uint16[] bonusesValues
    ) public {
        require(bonusesCounts.length == bonusesValues.length);
        tokenHandlerAddress = tokenHandler;
        beneficiary = ifSuccessfulSendTo;
        softFundingGoal = softFundingGoalInEthers * 1 ether;
        hardFundingGoal = hardFundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = Token(addressOfTokenUsedAsReward);
        bonusesCount = bonusesCounts.length;
        for (uint256 i = 0; i < bonusesCount; i++){
            bonuses[i] = Bonus(bonusesCounts[i], bonusesValues[i]);
        }
    }

    function () public payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        uint count = amount / price + (amount % price > 0 ? 1 : 0);
        uint16 bonus = getBonusOf(amount);
        count += bonus * count / 100 + ((bonus * count) % 100 > 0 ? 1 : 0) ;
        if (tokenReward.allowance(tokenHandlerAddress, address(this)) >= count){
            balance[msg.sender] += amount;
            amountRaised += amount;
            tokenReward.transfer(msg.sender, count);
            FundTransfer(msg.sender, amount, true);
        } else {
            revert();
        }
    }

    function getBonusOf(uint amount) public constant returns (uint16 value){
        for (uint256 i = bonusesCount - 1; i >= 0; i--){
            if (amount >= bonuses[i].amount * 1 ether){
                return bonuses[i].value;
            }
        }
        return 0;
    }

    function getBonusesCount() public constant returns (uint256 count){
        return bonusesCount;
    }

    function getBonusAmountByIndex(uint256 index) public constant returns (uint32 value){
        return bonuses[index].amount;
    }

    function getBonusValueByIndex(uint256 index) public constant returns (uint16 value){
        return bonuses[index].value;
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    function checkSoftGoalReached() public afterDeadline {
        if (amountRaised >= softFundingGoal){
            fundingGoalReached = true;
            SoftGoalReached(beneficiary, amountRaised);
        }
    }

    function checkHardGoalReached() public afterDeadline {
        if (amountRaised >= hardFundingGoal){
            HardGoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    function safeWithdrawal() public afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balance[msg.sender];
            balance[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balance[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
        }
    }
}
