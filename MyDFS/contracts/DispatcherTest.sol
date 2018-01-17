pragma solidity ^0.4.18;

import './Ownable.sol';
import './MyDFSToken.sol';

contract DispatcherTest {

	struct GameRequest {
		uint32 userId;
		uint32 amount;
	}

	struct GameTemplate {
		uint32 entryFee;
		uint32 serviceFee;
		uint32 dueDate;
	}

	MyDFSToken public gameToken;

	mapping (address => uint32) users;
	mapping (uint32 => uint32) public balances;
	mapping (uint32 => GameRequest[]) requests;

	mapping (uint32 => GameTemplate) games;

	event Participated(uint32 _user_id, uint32 _gameId);
	event Debug(uint gas);

	function Dispatcher(address _gameTokenAddress) public {
		require(_gameTokenAddress > 0);
		gameToken = MyDFSToken(_gameTokenAddress);
	}

	function addUser(address _user, uint32 _id) public {
		users[_user] = _id;
		balances[_id] = 1000;
	}

	function createGame(
		uint32 _gameId,
		uint32 _entryFee,
		uint32 _serviceFee,
		uint32 _dueDate
	) public {
		games[_gameId] = GameTemplate(_entryFee, _serviceFee, _dueDate);
	}

	function participateGame(uint32[] _user_ids, uint32 _gameId) public {
		uint32 entryFee = games[_gameId].entryFee;
		for (uint i = 0; i < _user_ids.length; i++) {
            require(balances[_user_ids[i]] >= entryFee);
        }

        for (i = 0; i < _user_ids.length; i++) {
			balances[_user_ids[i]] = balances[_user_ids[i]] - entryFee;
			requests[_gameId].push(GameRequest(_user_ids[i], entryFee));
		}
	}
}