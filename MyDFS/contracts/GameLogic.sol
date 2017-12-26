pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

contract GameLogic {

	struct Player {
		address user;
		address beneficiary;
		int32[] team;
		int32 score;
		uint32 prize;
	}

	Player[] players;
	uint8[] activeRule;
	mapping(int32 => int32) scores;
	mapping(int32 => mapping (int32 => int32)) rules;
	
	uint8[] smallGameRules;
	uint8[] largeGameRules;

	Player tmpPlayer;

	Stats stats;

	uint32 gameEntry;

	function compileRules(int32[] rulesFlat) external {
        for (uint32 i = 0; i < rulesFlat.length; i+=3) {
			rules[rulesFlat[i + 1]][rulesFlat[i]] = rulesFlat[i + 2];
		}
    }

    function compileGameStats(int32[] sportsmenFlatData) external {
        uint32 i = 0;
		while (i < sportsmenFlatData.length) {
			int32 sportsmanId = sportsmenFlatData[i];
			int32 roleId = sportsmenFlatData[i + 1];
			uint32 actionsCount = (uint32)(sportsmenFlatData[i + 2]);
			for (uint32 j = i + 3; j < i + actionsCount + 3; j += 2){
				int32 actionId = sportsmenFlatData[j];
				int32 count = sportsmenFlatData[j + 1];
				scores[sportsmanId] += rules[roleId][actionId] * count;
			}
			i += actionsCount + 2 + 1;
		}
    }
    
    function calculatePlayersScores() external {
        for (uint32 i = 0; i < players.length; i++){
			for (uint32 j = 0; j < players[i].team.length; j++){
				players[i].score += scores[players[i].team[j]];
			}
		}
    }
    
    function calculateWinners(uint256 prize) external {
        uint32 place = 0;
		uint32 counter = 0;
		uint32[] memory tmpArray = new uint32[](players.length);
        uint32 tmpArraySize;
	    activeRule = players.length > 100 ? largeGameRules : smallGameRules;
		while (place < activeRule.length && counter < players.length) {
			uint32 current = counter;
			counter++;
			tmpArraySize = 1;
			tmpArray[tmpArraySize - 1] = current;
			while (counter < players.length && players[current].score == players[counter].score){
				tmpArraySize++;
                tmpArray[tmpArraySize - 1] = counter;
				counter++;
			}
			uint32 placePrizePercent = 0;
			for (uint32 pIndex = place; pIndex < place + tmpArraySize; pIndex++) {
				if (pIndex < activeRule.length) {
					placePrizePercent += activeRule[pIndex];
				}
			}
			for (uint32 wIndex = 0; wIndex < tmpArraySize; wIndex++) {
				players[tmpArray[wIndex]].prize = (uint32)(prize) * placePrizePercent / (100 * tmpArraySize);
			}
			place += tmpArraySize;
		}
    }
    
    function updateUsersStats() external {
        for (uint32 i = 0; i < players.length; i++){
            stats.incStat(players[i].user, players[i].prize > 0, gameEntry, players[i].prize);
        }
    }

	function sortPlayers() external {
        if (players.length == 0)
            return;
        quickSort(0, players.length - 1);
    }
    
    function quickSort(
    	uint256 left, 
    	uint256 right
    ) 
    	internal 
    {
        uint256 i = left;
        uint256 j = right;
        while (i <= j) {
            while (i < players.length && players[i].score > players[left + (right - left) / 2].score) i++;
            while (j >= 0 && players[left + (right - left) / 2].score > players[j].score) j--;
            if (i <= j) {
                tmpPlayer = players[i];
                players[i] = players[j];
                players[j] = tmpPlayer;
                i++;
                if (j > 0) {
                    j--;
                }
            }
        }
        if (left < j)
            quickSort(left, j);
        if (i < right)
            quickSort(i, right);
    }

	function abs(
		int32 a
	) 
		internal
		pure
		returns (int32) 
	{
		return (a < 0) ? -a : a;
	}

}