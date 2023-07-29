// SPDX-License-Identifier: None
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Counters.sol';

contract Bet {
    using Counters for Counters.Counter;

    struct Player{
        address addr;
        uint256 amount;
    }

    struct Round{
        Player proposer;
        Player opponent;
        address withness;
        Status status;
    }

    enum Status {
        Gaming,
        Tying,
        Ended
    }

    event Proposal(address, address, uint256);
    event Result(address winner, uint256 round);

    mapping(address => uint256) private nonce;
    mapping(uint256 => Round) private rounds;
    Counters.Counter private current_round;

    constructor(){}

    function get_nonce(address _address) public view returns (uint){
        return nonce[_address];
    }

    function get_current_round() public view returns (uint){
        return current_round.current();
    }

    function create_round(Round calldata _round) public returns(bool){
        

        uint current = current_round.current();
        rounds[current] = _round;
        return true;
    }
}