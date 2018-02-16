pragma solidity ^0.4.18;

import '../GrowthTokensHolder.sol';

// @dev DevTokensHolderMock mocks current block number

contract GrowthTokensHolderMock is GrowthTokensHolder {

    uint mock_time;

    function GrowthTokensHolderMock(address _crowdsale, address _token, address _owner)
    GrowthTokensHolder(_crowdsale, _token, _owner) {
        mock_time = now;
    }

    function getTime() internal view returns (uint) {
        return mock_time;
    }

    function setMockedTime(uint _t) public {
        mock_time = _t;
    }
}