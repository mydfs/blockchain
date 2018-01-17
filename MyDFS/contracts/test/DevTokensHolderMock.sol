pragma solidity ^0.4.18;

import '../DevTokensHolder.sol';

// @dev DevTokensHolderMock mocks current block number

contract DevTokensHolderMock is DevTokensHolder {

    uint mock_time;

    function DevTokensHolderMock(address _crowdsale, address _token, address _owner)
    DevTokensHolder(_crowdsale, _token, _owner) {
        mock_time = now;
    }

    function getTime() internal view returns (uint) {
        return mock_time;
    }

    function setMockedTime(uint _t) public {
        mock_time = _t;
    }
}