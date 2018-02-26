pragma solidity ^0.4.18;

import '../AdvisorsTokensHolder.sol';

// @dev DevTokensHolderMock mocks current block number

contract AdvisorsTokensHolderMock is AdvisorsTokensHolder {

    uint mock_time;

    function AdvisorsTokensHolderMock(address _crowdsale, address _token, address _owner)
    AdvisorsTokensHolder(_crowdsale, _token, _owner) {
        mock_time = now;
    }

    function getTime() internal view returns (uint) {
        return mock_time;
    }

    function setMockedTime(uint _t) public {
        mock_time = _t;
    }
}