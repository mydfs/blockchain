pragma solidity ^0.4.18;

import './Ownable.sol';

contract Arbitrator is Ownable {

    enum State { Initialized, Started, Finished, Cancelled }

	struct Game {
		State state;
		uint32 entryFee;
		uint32 serviceFee;
		uint32 registrationDueDate;
	}

	mapping (uint32 => Game) games;

    /**
     * Constrctor function
     */
	function Arbitrator(address _gameTokenAddress) public {
		require(_gameTokenAddress > 0);
	}

	function tokenFallback(
        address _from, 
        uint _value, 
        bytes _data
    ) 
        public 
        view 
    {
    }

	/**
     * Create new game
     */
	function createGame(
		uint32 _gameId,
		uint32 _entryFee,
		uint32 _serviceFee,
		uint32 _registrationDueDate
	)
		external
		onlyOwner
	{
		require(
			games[_gameId].entryFee == 0
			&& _gameId > 0
			&& _entryFee > 0
			&& _registrationDueDate > 0
		);
		games[_gameId] = Game(State.Initialized, _entryFee, _serviceFee, _registrationDueDate);
	}

	/**
     * Stop participate game, log teams hash
     */
	function startGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		Game game = games[_gameId];
		require(
			_gameId > 0
			&& game.state == State.Initialized
			&& _hash != 0x0
		);
		game.state = State.Started;
	}

	/**
     * Cancel game
     */
	function cancelGame(uint32 _gameId)	external onlyOwner {
		Game game = games[_gameId];
		require(
			_gameId > 0
			&& game.state == State.Started
		);
		game.state = State.Cancelled;
	}

	/**
     * Finish game, store events hash
     */
	function finishGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		Game game = games[_gameId];
		require(
			_gameId > 0
			&& game.state == State.Started
			&& _hash != 0x0
		);
		
		game.state = State.Finished;
	}

	function withdraw(address _user, uint32 sum) external onlyOwner {
		
	}
}