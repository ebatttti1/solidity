// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract DAO {
    address immutable owner;
    IERC20 public token;
    uint public proposalCounter;
    uint public proposalDuration;
    uint immutable tokenPrice = 1e18;

    struct Proposal {
        string description;
        uint voteCount;
        uint startTime;
        bool executed;
    }

    mapping (uint => Proposal) public proposals;
    mapping (address => uint) public tokenBalance;
    mapping (uint => mapping (address => bool)) public isVoted;

    event Buy(address buyer, uint tokenAmount, uint paidAmount);
    event CreateProposal(address creator, string description, uint createdTime);
    event Vote(address voter, uint index);
    event Execute(address owner, string description, uint voteCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call the contract");
        _;
    }

    modifier onlyHolder() {
        require(tokenBalance[msg.sender] > 0, "only holder can create and vote");
        _;
    }

    constructor(address _token, uint _proposalDuration) {
        token = IERC20(_token);
        proposalDuration = _proposalDuration;
    }

    function pay() external payable {
        require(msg.value >= 1 ether, "not enough ether to buy token");
        uint tokenBought = msg.value / tokenPrice;
        tokenBalance[msg.sender] += tokenBought;
        emit Buy(msg.sender, tokenBought, msg.value);
    }

    function createProposal(string memory _description) external onlyHolder {
        proposals[proposalCounter] = Proposal({
            description: _description,
            voteCount: 0,
            startTime: block.timestamp,
            executed: false
        });
        proposalCounter++;
        emit CreateProposal(msg.sender, _description, block.timestamp);
    }

    function vote(uint _index) external onlyHolder {
        Proposal storage proposal = proposals[_index];
        require(!isVoted[_index][msg.sender], "already voted");
        require(block.timestamp < (proposal.startTime + proposalDuration), "duration is ended");
        proposal.voteCount += tokenBalance[msg.sender];
        isVoted[_index][msg.sender] = true;
        emit Vote(msg.sender, _index);
    }

    function executeProposal(uint _index) external onlyOwner {
        Proposal storage proposal = proposals[_index];
        require(_index <= proposalCounter, "invalid index");
        require(block.timestamp > (proposal.startTime + proposalDuration), "error: voting is not finished yet");
        require(!proposal.executed, "already executed");
        proposal.executed = true;
        emit Execute(owner, proposal.description, proposal.voteCount);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "this address balance is zero");
        payable (owner).transfer(address(this).balance);
    }
}