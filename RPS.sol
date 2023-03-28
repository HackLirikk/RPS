// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract flipFlop {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "Only owner");
        _;
    }

    event GetRes(address player, uint option, uint result, uint optioncomp);

    function withdraw() public OnlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  msg.sender))) % 3 + 1;
    }

    function playGame(uint _playerOneChoice) payable public returns(uint){
        require(address(this).balance >= msg.value*2, "Smart-contract run out of funds");
        require(msg.value >= 100000 gwei);

        uint _playerTwoChoice = random();
        bytes memory b = bytes.concat(bytes(Strings.toString(_playerOneChoice)), bytes(Strings.toString(_playerTwoChoice)));

        uint rslt;

        if(keccak256(b) == keccak256(bytes("11"))
            || keccak256(b) == keccak256(bytes("22"))
            || keccak256(b) == keccak256(bytes("33")))
        {
            //this is a draw
            rslt = 0;
            payable(msg.sender).transfer(msg.value);
        } else if(keccak256(b) == keccak256(bytes("32"))
            || keccak256(b) == keccak256(bytes("13"))
            || keccak256(b) == keccak256(bytes("21")))
        {
            //player 1 wins
            payable(msg.sender).transfer(msg.value * 2);
            rslt = 1;
        } else if(keccak256(b) == keccak256(bytes("23"))
            || keccak256(b) == keccak256(bytes("31"))
            || keccak256(b) == keccak256(bytes("12")))
        {
            //player 2 wins (the contract wins)
            rslt = 2;
        }
        else {
            //there was a problem with this game...
            rslt = 3;
        }

        emit GetRes(msg.sender, _playerOneChoice, rslt, _playerTwoChoice);

        return rslt;

    }

    receive () external payable {}
}
