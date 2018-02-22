pragma solidity ^0.4.18;

import './Ownable.sol';
import './MyDFSToken.sol';

contract Dispatcher is Ownable {

	enum GameState { Initialized, Started, Finished, Cancelled }

	struct GameTeam {
		uint32 userId;
		uint32 sponsorId;
		uint64 prizeSum;
	}

	struct Game {
		GameState state;
		uint64 entryFee;
		uint32 serviceFee;
		uint32 registrationDueDate;

		bytes32 teamsHash;
		bytes32 statsHash;

		uint32 teamsNumber;
		uint64 awardSent;
	}

	MyDFSToken public gameToken;

	/** player ids (store optimisation) **/
	mapping (address => uint32) public users;
	/** player balances **/
	mapping (uint32 => uint64) public balances;
	/** invesor fees **/
	mapping (uint32 => uint8) public playersFee;
	/** player teams **/
	mapping (uint32 => mapping (uint48 => GameTeam)) public teams;
	/** games **/
	mapping (uint32 => Game) public games;

	/** service reward can be withdraw by owners **/
	uint serviceReward;

	event Participated(uint32 _teamId, uint32 _userId, uint32 _sponsorId, uint32 _gameId);
	event Debug(uint sum);

    /**
     * Constrctor function
     */
	function Dispatcher(address _gameTokenAddress) public {
		require(_gameTokenAddress > 0);
		gameToken = MyDFSToken(_gameTokenAddress);
	}

    /**
     * Register user
     */
	function registerUser(address _user, uint32 _id) external onlyOwner {
		require(users[_user] == 0);
		users[_user] = _id;
		balances[_id] = 0;
	}

	/**
     * Create new game
     */
	function createGame(
		uint32 _gameId,
		uint64 _entryFee,
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
		games[_gameId] = Game(GameState.Initialized, _entryFee, _serviceFee, _registrationDueDate, 0x0, 0x0, 0, 0);
	}

	/**
     * Participate game
     */
	function participateGame(
		uint32 _gameId,
		uint32 _teamId, 
		uint32 _userId, 
		uint32 _sponsorId
	) 
		external 
		onlyOwner 
	{
		Game storage game = games[_gameId];
		require(
			_gameId > 0
			&& game.state == GameState.Initialized
			&& _teamId > 0
			&& _userId > 0
			&& teams[_gameId][_teamId].userId == 0
			&& game.registrationDueDate > uint32(now)
		);

		if (_sponsorId > 0) {
			require(balances[_sponsorId] >= game.entryFee);
			balances[_sponsorId] = balances[_sponsorId] - game.entryFee;
		}
		else {
			require(balances[_userId] >= game.entryFee);
			balances[_userId] = balances[_userId] - game.entryFee;
		}

		teams[_gameId][_teamId] = GameTeam(_userId, _sponsorId, 0);
		game.teamsNumber++;
		Participated(_teamId, _userId, _sponsorId, _gameId);
	}

	/**
     * Stop participate game, store teams hash
     */
	function startGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		Game storage game = games[_gameId];
		require(
			game.state == GameState.Initialized
			&& _gameId > 0
			&& _hash != 0x0
		);
		
		game.teamsHash = _hash;
		game.state = GameState.Started;
	}

	/**
     * Cancel game
     */
	function cancelGame(uint32 _gameId)	external onlyOwner {
		Game storage game = games[_gameId];
		require(
			_gameId > 0
			&& game.state < GameState.Finished
		);
		game.state = GameState.Cancelled;
	}

	/**
     * Finish game, store stats hash
     */
	function finishGame(uint32 _gameId, bytes32 _hash) external onlyOwner {
		Game storage game = games[_gameId];
		require(
			_gameId > 0
			&& game.state < GameState.Finished
			&& _hash != 0x0
		);
		game.statsHash = _hash;
		game.state = GameState.Finished;
	}

	/**
     * Reward winners
     */
	function winners(uint32 _gameId, uint32[] _teamIds, uint64[] _teamPrizes) external onlyOwner {
		Game storage game = games[_gameId];
		require(game.state == GameState.Finished);

		uint64 sumPrize = 0;
		for (uint32 i = 0; i < _teamPrizes.length; i++)
			sumPrize += _teamPrizes[i];

		require(uint(sumPrize + game.awardSent) <= uint(game.entryFee * game.teamsNumber));

		for (i = 0; i < _teamIds.length; i++) {
			uint32 teamId = _teamIds[i];
			GameTeam storage team = teams[_gameId][teamId];
			uint32 userId = team.userId;

			if (team.prizeSum == 0) {
				if (team.sponsorId > 0) {
					uint64 playerFee = _teamPrizes[i] * playersFee[userId] / 100;
					balances[userId] += playerFee;
					balances[team.sponsorId] += _teamPrizes[i] - playerFee;
					team.prizeSum = _teamPrizes[i];
				} else {
					balances[userId] += _teamPrizes[i];
					team.prizeSum = _teamPrizes[i];
				}
			}
		}
	}

	/**
     * Refund money for cancelled game
     */
	function refundCancelledGame(uint32 _gameId, uint32[] _teamIds) external onlyOwner {
		Game storage game = games[_gameId];
		require(game.state == GameState.Cancelled);

		for (uint32 i = 0; i < _teamIds.length; i++) {
			uint32 teamId = _teamIds[i];
			GameTeam storage team = teams[_gameId][teamId];

			require(teams[_gameId][teamId].prizeSum == 0);

			if (team.prizeSum == 0) {
				if (team.sponsorId > 0) {
					balances[team.sponsorId] += game.entryFee;
				} else {
					balances[team.userId] += game.entryFee;
				}
				team.prizeSum = game.entryFee;
			}
		}
	}

	/**
     * Deposits from user
     */
	function tokenFallback(address _from, uint _amount, bytes _data) public {
		require(
			users[_from] > 0 || _data.length > 0
		);
		balances[users[_from]] += uint64(_amount);
	}

	/**
     * Deposits tokens in game
     */
	function deposit(uint64 _sum) external {
		require(
			gameToken.balanceOf(msg.sender) >= _sum
			&& users[msg.sender] > 0
		);

		if (gameToken.transferFrom(msg.sender, address(this), _sum))
			balances[users[msg.sender]] += _sum;		
	}

	/**
     * User can withdraw tokens manually in any time
     */
	function withdraw(uint64 _amount) external {
		require(
			users[msg.sender] > 0
			&& balances[users[msg.sender]] >= _amount
		);

		if (gameToken.transfer(msg.sender, _amount))
			balances[users[msg.sender]] -= _amount;
	}

	/**
     * User can withdraw tokens manually in any time
     */
	function systemWithdraw(address _user, uint64 _amount) external onlyOwner {
		require(
			_user != 0x0
			&& balances[users[_user]] >= _amount
		);

		if (gameToken.transfer(_user, _amount))
			balances[users[_user]] -= _amount;
	}

	/**
     * Check user balance
     */
	function balanceOf(
		address _user
	)
		public
		constant
		returns (uint64)
	{
		return balances[users[_user]];
	}
}