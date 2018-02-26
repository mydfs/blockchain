pragma solidity ^0.4.18;

import '../GenericCrowdsale.sol';

// @dev DevTokensHolderMock mocks current block number

contract GenericCrowdsaleMock is GenericCrowdsale {

    uint mock_time;

    function GenericCrowdsaleMock(address ifSuccessfulSendTo, address addressOfTokenUsedAsReward)
    GenericCrowdsale(ifSuccessfulSendTo, addressOfTokenUsedAsReward) {
        mock_time = now;
    }

    function getTime() internal view returns (uint) {
        return mock_time;
    }

    function setMockedTime(uint _t) public {
        mock_time = _t;
    }
}