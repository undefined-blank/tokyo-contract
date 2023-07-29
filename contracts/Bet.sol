// SPDX-License-Identifier: None
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';
import './utils/Signer.sol';

contract Bet {
    using Counters for Counters.Counter;

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

    event Proposal(address, address, uint256);
    event Result(address winner, uint256 round);

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
        games[current_game_id.current()] = new_game;
    }

    function join_game(uint game_id) public payable returns(bool){
        Game storage _game = games[game_id];
        require(msg.value >= _game.amount, "Game: Transfer value should more than amount");
        _game.receiver.amount = msg.value;
    }

    function verify(uint game_id, address winner,
        bytes32 signature){
            
    }
}