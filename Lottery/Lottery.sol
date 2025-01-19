// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract lottery {
    
    address immutable owner;

    address [] public players;

    mapping (address => bool) public isPlayer;

    uint public enteryPrice = 1e18;

    receive() external payable { }

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner can call the function");
        _;
    }

    modifier notPlayer(address _wallet) {
        require(!isPlayer[_wallet], "already entered");
        _;
    }

    function enterLottery() external payable notPlayer(msg.sender) {
        require(msg.sender.balance >= 2 ether && msg.value == 1e18, "not enough balance to enter");
        payable (address(this)).transfer(msg.value);
        players.push(msg.sender);
        isPlayer[msg.sender] = true;
    }

    function pickWinner() external onlyOwner returns (uint, address) {
        uint rnd = uint(keccak256(abi.encodePacked(block.timestamp, block.gaslimit)));
        uint i = rnd % players.length;
        address winner = players[i];
        payable (winner).transfer(address(this).balance);
        return (i , players[i]);
    }
}