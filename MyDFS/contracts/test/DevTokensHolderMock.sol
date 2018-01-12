pragma solidity ^0.4.18;

import '../DevTokensHolder.sol';

// @dev DevTokensHolderMock mocks current block number

contract DevTokensHolderMock is DevTokensHolder {

    uint mock_time;

    function DevTokensHolderMock(address _contribution, address _snt)
    DevTokensHolder(_contribution, _snt) {
        mock_time = now;
    }

    function getTime() internal view returns (uint) {
        return mock_time;
    }

    function setMockedTime(uint _t) public {
        mock_time = _t;
    }
}