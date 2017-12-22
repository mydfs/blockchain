pragma solidity ^0.4.16;

import './interface/Token.sol';
import './interface/Stats.sol';
import './interface/Broker.sol';

library MyDFSGameLogic {

	struct Player {
		address user;
		address beneficiary;
		int32[] team;
		int32 score;
		uint32 prize;
	}

	struct Data {
		Player[] players;
		uint8[] activeRule;
		mapping(int32 => int32) scores;
		mapping(int32 => mapping (int32 => int32)) rules;
	
		mapping (address => uint8) teamsCount; 
	
		uint8[] smallGameRules;
		uint8[] largeGameRules;

		Player tmpPlayer;
	}

	function compileRules(Data storage self, int32[] rulesFlat) internal {
        for (uint32 i = 0; i < rulesFlat.length; i+=3) {
			self.rules[rulesFlat[i + 1]][rulesFlat[i]] = rulesFlat[i + 2];
		}
    }

    function compileGameStats(Data storage self, int32[] sportsmenFlatData) internal {
        uint32 i = 0;
		while (i < sportsmenFlatData.length) {
			int32 sportsmanId = sportsmenFlatData[i];
			int32 roleId = sportsmenFlatData[i + 1];
			uint32 actionsCount = (uint32)(sportsmenFlatData[i + 2]);
			for (uint32 j = i + 3; j < i + actionsCount + 3; j += 2){
				int32 actionId = sportsmenFlatData[j];
				int32 count = sportsmenFlatData[j + 1];
				self.scores[sportsmanId] += self.rules[roleId][actionId] * count;
			}
			i += actionsCount + 2 + 1;
		}
    }
    
    function calculatePlayersScores(Data storage self) internal {
        for (uint32 i = 0; i < self.players.length; i++){
			for (uint32 j = 0; j < self.players[i].team.length; j++){
				self.players[i].score += self.scores[self.players[i].team[j]];
			}
		}
    }
    
    function calculateWinners(Data storage self, uint256 prize) internal {
        uint32 place = 0;
		uint32 counter = 0;
		uint32[] memory tmpArray = new uint32[](self.players.length);
        uint32 tmpArraySize;
	    self.activeRule = self.players.length > 100 ? self.largeGameRules : self.smallGameRules;
		while (place < self.activeRule.length && counter < self.players.length) {
			uint32 current = counter;
			counter++;
			tmpArraySize = 1;
			tmpArray[tmpArraySize - 1] = current;
			while (counter < self.players.length && self.players[current].score == self.players[counter].score){
				tmpArraySize++;
                tmpArray[tmpArraySize - 1] = counter;
				counter++;
			}
			uint32 placePrizePercent = 0;
			for (uint32 pIndex = place; pIndex < place + tmpArraySize; pIndex++) {
				if (pIndex < self.activeRule.length) {
					placePrizePercent += self.activeRule[pIndex];
				}
			}
			for (uint32 wIndex = 0; wIndex < tmpArraySize; wIndex++) {
				self.players[tmpArray[wIndex]].prize = (uint32)(prize) * placePrizePercent / (100 * tmpArraySize);
			}
			place += tmpArraySize;
		}
    }
    
    function updateUsersStats(Stats stats, Player[] players, uint32 gameEntry) internal {
        for (uint32 i = 0; i < players.length; i++){
            stats.incStat(players[i].user, players[i].prize > 0, gameEntry, players[i].prize);
        }
    }

	function sortPlayers(Data storage self) internal {
        if (self.players.length == 0)
            return;
        quickSort(self, 0, self.players.length - 1);
    }
    
    function quickSort(
    	Data storage self,
    	uint256 left, 
    	uint256 right
    ) 
    	internal 
    {
        uint256 i = left;
        uint256 j = right;
        while (i <= j) {
            while (i < self.players.length && self.players[i].score > self.players[left + (right - left) / 2].score) i++;
            while (j >= 0 && self.players[left + (right - left) / 2].score > self.players[j].score) j--;
            if (i <= j) {
                self.tmpPlayer = self.players[i];
                self.players[i] = self.players[j];
                self.players[j] = self.tmpPlayer;
                i++;
                if (j > 0) {
                    j--;
                }
            }
        }
        if (left < j)
            quickSort(self, left, j);
        if (i < right)
            quickSort(self, i, right);
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