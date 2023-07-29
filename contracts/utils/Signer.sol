// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '../Bet.sol';

contract Signer {
    struct Message{
        address proposer;
        address receiver;
        address withness;
        uint amount;
    }
    
    struct Judge{
        uint256 game_id;
        address winner;
    }

    bytes32 constant PERMIT_TYPEHASH = keccak256(
        "Permit(address proposer,address receiver,address withness,unit256 amount)"
    );

    bytes32 constant JUDGE_TYPEHASH = keccak256(
        "Judge(uint256 game_id,address winner)"
    );
    
    bytes32 public DOMAIN_SEPARATOR;

    constructor(){
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('BETDomain(string name,string version,unit256 chainId,address verifyingContract)'),
                keccak256(bytes('Bet')),
                keccak256(bytes('1.0')),
                81,
                address(this)
            )
        );
    }
    
    function verify_proposer(
        address proposer, address receiver, address withness, uint256 amount,
        uint8 v, bytes32 r, bytes32 s
    ) public pure returns (bool){
        bytes32 hashedMessage = hashStruct_message(Message(proposer, receiver, withness, amount));

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashedMessage
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == proposer, "Verify: Fail");

        return true;
    }

    function verify_withness(
        address withness, uint256 game_id, address winner,
        uint8 v, bytes32 r, bytes32 s
    ) public view returns(bool){
        bytes32 hashedMessage = hashStruct_judge(Judge(game_id, winner));

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashedMessage
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == withness, "Veryfi: Fail");
        
        return true;
    }
    
    function hashStruct_message(Message memory _message) pure public returns (bytes32 hash){    
        return keccak256(abi.encode(
            PERMIT_TYPEHASH,
            _message.proposer,
            _message.receiver,
            _message.withness,
            _message.amount
        ));
    }   

    function hashStruct_judge(Judge memory _judge) pure public returns (bytes32 hash){
        return keccak256(abi.encode(
            JUDGE_TYPEHASH,
            _judge.game_id,
            _judge.winner
        ));
    }

}