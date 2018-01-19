pragma solidity ^0.4.18;

import './Ownable.sol';
import './MyDFSToken.sol';

contract DispatcherTest is Ownable {

	struct GameRequest {
		uint32 userId;
		uint32 sponsorId;
		uint32 prizeSum;
	}

	struct GameTemplate {
		uint32 entryFee;
		uint32 serviceFee;

		uint32 startTime;
		bytes32 teamsHash;
		
		uint32 finishTime;
		bytes32 eventsHash;

		uint32 teamsAmount;
		bool cancelled;
	}

	MyDFSToken public gameToken;

	mapping (address => uint32) users;
	mapping (uint32 => uint32) public balances;
	mapping (uint32 => mapping (uint48 => GameRequest)) teams;

	mapping (uint32 => GameTemplate) games;

	event Participated(uint32 _user_id, uint32 _gameId);
	event Debug(uint gas);

    /**
     * Constrctor function
     */
	function DispatcherTest(address _gameTokenAddress) public {
		require(_gameTokenAddress > 0);
		gameToken = MyDFSToken(_gameTokenAddress);
	}

    /**
     * Register user
     */
	function registerUser(address _user, uint32 _id) external onlyOwner {
		users[_user] = _id;
		balances[_id] = 1000;
	}

	/**
     * Create new game
     */
	function createGame(
		uint32 _gameId,
		uint32 _entryFee,
		uint32 _serviceFee
	) 
		external
		onlyOwner
	{
		require(
			games[_gameId].entryFee == 0
			&& _gameId > 0
			&& _entryFee > 0
		);
		games[_gameId] = GameTemplate(_entryFee, _serviceFee, 0, 0x0, 0, 0x0, 0, false);
	}

	/**
     * Participate game
     */
	function participateGame(uint32 _gameId, uint32[] _teamIds, uint32[] _userIds, uint32[] _sponsorIds) external onlyOwner {
		GameTemplate game = games[_gameId];
		require(
			_gameId > 0
			&& game.startTime == 0
			&& _teamIds.length == _userIds.length
			&& _teamIds.length == _sponsorIds.length
		);

		uint32 entryFee = game.entryFee;
		for (uint i = 0; i < _userIds.length; i++) {
            require(balances[_userIds[i]] >= entryFee);
        }

        for (i = 0; i < _userIds.length; i++) {
			balances[_userIds[i]] = balances[_userIds[i]] - entryFee;
			teams[_gameId][_teamIds[i]] = GameRequest(_userIds[i], _sponsorIds[i], 0);
			game.teamsAmount++;
		}
	}

	/**
     * Stop participate game, store teams hash
     */
	function startGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		GameTemplate game = games[_gameId];
		require(
			game.startTime == 0 
			&& _gameId > 0
			&& _hash != 0x0
		);
		
		game.startTime = uint32(now);
		game.teamsHash = _hash;
	}

	/**
     * Cancel game
     */
	function cancelGame(uint32 _gameId)	external onlyOwner {
		GameTemplate game = games[_gameId];
		require(
			_gameId > 0
			&& game.finishTime == 0
			&& game.startTime > 0
		);
		game.cancelled = true;
	}

	/**
     * Finish game, store events hash
     */
	function finishGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		GameTemplate game = games[_gameId];
		require(
			_gameId > 0
			&& game.finishTime == 0 
			&& game.startTime > 0 
			&& !game.cancelled
			&& _hash != 0x0
		);
		
		game.finishTime = uint32(now);
		game.eventsHash = _hash;
	}

	/**
     * Reward winners
     */
	function winners(uint32[] _teamIds, uint32[] _userPrizes, uint32 _gameId) external onlyOwner {
		for (i = 0; i < _teamIds.length; i++) {
			uint32 teamId = _teamIds[i];

			if (teams[_gameId][teamId].prizeSum == 0) {
				balances[_userIds[i]] = balances[_userIds[i]] + _userPrizes[i];
				teams[_gameId][teamId].prizeSum = _userPrizes[i];
			}
		}
	}
}