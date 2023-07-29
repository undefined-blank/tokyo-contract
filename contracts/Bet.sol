// SPDX-License-Identifier: None
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';
import './utils/Signer.sol';

contract Bet {
    using Counters for Counters.Counter;
    Signer signer = new Signer();

    struct Player{
        address addr;
        uint amount;
    }

    struct Game{
        Player proposer;
        Player receiver;
        address withness;
        uint amount;
        Status status;
    }

    enum Status {
        Creating,
        Gaming,
        Ended
    }

    event Creating(uint game_id, address proposer, address receiver, address withness, uint256 amount, Status);
    event Gaming(uint game_id, address proposer, address receiver, address withness, uint256 amount, Status);
    event Ended(uint game_id, address winner, uint256 amount, Status);

    mapping(uint256 => Game) private games;
    Counters.Counter private current_game_id;

    constructor(){}

    function get_current_game() public view returns (uint){
        return current_game_id.current();
    }

    function create_game(address receiver, address withness, uint amount) public payable returns(bool){
        require(msg.value >= amount, "Game: Transfer value should more than amount");

        Game memory new_game = Game(
            Player(
                msg.sender,
                msg.value
            ),
            Player(
                receiver,
                0
            ), 
            withness,
            amount,
            Status.Creating
        );

        current_game_id.increment();
        uint game_id_created = current_game_id.current();
        games[game_id_created] = new_game;
        emit Creating(game_id_created, msg.sender, receiver, withness, amount, Status.Creating);
    }

    function join_game(uint game_id) public payable returns(bool){
        Game storage _game = games[game_id];
        require(msg.value >= _game.amount, "Game: Transfer value should more than amount");
        _game.receiver.amount = msg.value;

        emit Gaming(game_id, _game.proposer.addr, msg.sender, _game.withness, _game.amount, Status.Gaming);
    }

    function claim(
        uint game_id, address payable winner,
        uint8 v, bytes32 r, bytes32 s
    ) public returns(bool){
        Game storage _game = games[game_id];

        bool isVerified = signer.verify_withness(_game.withness, game_id, winner, v, r, s);
        require(isVerified == true, "Claim: Not Verified");

        uint256 total_bet_amount = _game.proposer.amount + _game.receiver.amount;
        winner.transfer(total_bet_amount);

        _game.status = Status.Ended;
        emit Ended(game_id, msg.sender, _game.amount, Status.Ended);

        return true;
    }
}