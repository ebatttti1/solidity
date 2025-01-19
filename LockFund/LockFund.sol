// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract LockFund {
    address owner;
    
    mapping (address => uint) lockTime;
    mapping (address => uint) fundValue;
    mapping (address => bool) isMember;

    uint public lockDuration = 4 weeks;

    event LockToContract(address from, address to, uint depositAmount, uint time);
    event Withdraw(address from, address to, uint withdrawAmount, uint reward, uint time);

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    function lockToContract() external payable {
        require(!isMember[msg.sender], "you already deposit fund");
        require(msg.value >= 0.5 ether, "you can't lock less than 0.5 ether");
        lockTime[msg.sender] = block.timestamp;
        fundValue[msg.sender] = msg.value;
        isMember[msg.sender] = true;
        emit LockToContract(msg.sender, address(this), msg.value, block.timestamp);
    }

    function withdraw() external payable {
        require(isMember[msg.sender], "you are not member of this contract");
        require(block.timestamp > lockTime[msg.sender] + lockDuration, "lock time is not finished yet");
        require(fundValue[msg.sender] > 0, "you already withdraw your fund");
        payable (msg.sender).transfer(fundValue[msg.sender] + fundValue[msg.sender] * 10 / 100);
        emit Withdraw(address(this), msg.sender, fundValue[msg.sender] + fundValue[msg.sender] * 10 / 100, fundValue[msg.sender] * 10 / 100, block.timestamp);
        delete lockTime[msg.sender];
        delete isMember[msg.sender];
        delete fundValue[msg.sender];
    }

    function ownerAdr() public view returns(address) {
        return owner;
    }

    function checkIsMember(address _adr) public view onlyOwner returns (bool) {
        return isMember[_adr];
    }

    function checkLockTime(address _adr) public view onlyOwner returns (uint) {
        return lockTime[_adr];
    }

    function checkFundValue(address _adr) public view onlyOwner returns (uint, string memory) {
        return (fundValue[_adr] / 1e18 , "ETH");
    }
}