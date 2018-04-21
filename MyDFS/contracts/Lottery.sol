pragma solidity ^0.4.18;

import './Ownable.sol';

contract Lottery is Ownable {

	struct Stage {
		uint32 maxNum;
		bytes32 participantsHash;
		uint winnerNum;
	}
	mapping (uint32 => Stage) public stages;

	event Winner(uint32 _stageNum, uint _winnerNum);

    /**
     * Register user
     */
	function randomJackpot(uint32 _stageNum, bytes32 participantsHash, uint32 maxNum) external onlyOwner {
		require(maxNum > 0);
		uint winnerNum = uint(block.blockhash(block.number - 1)) % maxNum + 1;
		stages[_stageNum] = Stage(maxNum, participantsHash, winnerNum);
		emit Winner(_stageNum, winnerNum);
	}
}