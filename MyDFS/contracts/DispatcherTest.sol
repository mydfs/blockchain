pragma solidity ^0.4.18;

import './Ownable.sol';
import './MyDFSToken.sol';

contract DispatcherTest is Ownable {

	struct GameRequest {
		uint32 userId;
		uint32 amount;
	}

	struct GameTemplate {
		uint32 entryFee;
		uint32 serviceFee;

		uint32 startTime;
		bytes32 teamsHash;
		
		uint32 finishTime;
		bytes32 eventsHash;

		bool cancelled;
	}

	MyDFSToken public gameToken;

	mapping (address => uint32) users;
	mapping (uint32 => uint32) public balances;
	mapping (uint32 => GameRequest[]) requests;

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
		require(games[_gameId] == 0);

		games[_gameId] = GameTemplate(_entryFee, _serviceFee, 0, 0x0, 0, 0x0, false);
	}

	/**
     * Participate game
     */
	function participateGame(uint32[] _userIds, uint32 _gameId) external onlyOwner {
		require(games[_gameId].startTime == 0);

		uint32 entryFee = games[_gameId].entryFee;
		for (uint i = 0; i < _userIds.length; i++) {
            require(balances[_userIds[i]] >= entryFee);
        }

        for (i = 0; i < _userIds.length; i++) {
			balances[_userIds[i]] = balances[_userIds[i]] - entryFee;
			requests[_gameId].push(GameRequest(_userIds[i], entryFee));
		}
	}

	/**
     * Stop participate game, store teams hash
     */
	function startGame(uint32 _gameId, bytes32 _hash)	external onlyOwner {
		GameTemplate game = games[_gameId];
		require(game.startTime == 0);
		
		game.startTime = uint32(now);
		game.teamsHash = _hash;
	}

	/**
     * Cancel game
     */
	function cancelGame(uint32 _gameId)	external onlyOwner {
		GameTemplate game = games[_gameId];
		require(game.finishTime == 0 && game.startTime > 0);
		game.cancelled = true;
	}

	/**
     * Finish game, store events hash
     */
	function finishGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		GameTemplate game = games[_gameId];
		require(game.finishTime == 0 && game.startTime > 0 && !game.cancelled);
		
		game.finishTime = uint32(now);
		game.eventsHash = _hash;
	}

	/**
     * Reward winners
     */
	function winners(uint32[] _userIds, uint32[] _userPrizes, uint32 _gameId) external onlyOwner {
		for (i = 0; i < _userIds.length; i++) {
			balances[_userIds[i]] = balances[_userIds[i]] + _userPrizes[i];
		}
	}
}