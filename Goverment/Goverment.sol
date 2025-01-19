// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract Goverment {
    address owner;    

    constructor() {
        owner = msg.sender;
    }

    struct Citizen {
        string fullName;
        uint age;
        uint id;
        address wallet;
    }
    Citizen [] citizenList;

    struct Officials {
        string officialName;
        uint id;
        uint enactedProposal;
        address wallet;
    }
    Officials [] officialList;

    struct LawProposals {
        string law;
        uint voteCount;
        bool enacted;
    }
    LawProposals [] lawProposalList;

    mapping (address => bool) public isCitizen;
    mapping (address => bool) public isOfficial;
    mapping (uint => mapping (address => bool)) isVoted;

    modifier onlyOwner {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }

    function registerCitizen(string memory _fullName, uint _age, uint _id) public {
        require(!isCitizen[msg.sender], "this address already registered as a citizen");
        citizenList.push(Citizen({
            fullName: _fullName,
            age: _age,
            id: _id,
            wallet: msg.sender
        }));
        isCitizen[msg.sender] = true;
    }

    function registerOfficial(string memory _officialName, uint _id, address _wallet) public onlyOwner {
        require(!isOfficial[_wallet], "this address already registered as a official");
        officialList.push(Officials({
            officialName: _officialName,
            id: _id,
            enactedProposal: 0,
            wallet: _wallet
        }));
        isOfficial[_wallet] = true;
    }

    function proposeLaw(string memory _law) public {
        require(isOfficial[msg.sender], "only officials can call this function");
        lawProposalList.push(LawProposals({
            law: _law,
            voteCount: 0,
            enacted: false
        }));
    }

    function vote(uint _index) public {
        require(!isVoted[_index][msg.sender], "this address already voted to this law.");
        require(isCitizen[msg.sender], "only citizen can call this function");
        isVoted[_index][msg.sender] = true;
        lawProposalList[_index].voteCount++;
    }

    function enactLaw(uint _index) public onlyOwner {
        require(lawProposalList[_index].voteCount >= (citizenList.length / 2) + 1 , "Not enough votes to enact.");
        require(!lawProposalList[_index].enacted , "Law already enacted.");
        lawProposalList[_index].enacted = true;
    }

    function getAllOfficials() public view onlyOwner returns (Officials [] memory) {
        return officialList;
    }

    function getAllCitizens() public view onlyOwner returns (Citizen[] memory) {
        return citizenList;
    }

    function getAllProposal() public view onlyOwner returns (LawProposals [] memory) {
        return lawProposalList;
    }

    function getOfficials(uint _index) public view onlyOwner returns (Officials memory) {
        require(_index >= 0 && _index < officialList.length, "index out of range");
        return officialList[_index];
    }

    function getCitizens(uint _index) public view onlyOwner returns (Citizen memory) {
        require(_index >= 0 && _index < citizenList.length, "index out of range");
        return citizenList[_index];
    }

    function getProposal(uint _index) public view onlyOwner returns (LawProposals memory) {
        require(_index >= 0 && _index < lawProposalList.length, "index out of range");
        return lawProposalList[_index];
    }

    function removeCitizen(uint _index) public onlyOwner {
        require(_index >= 0 && _index < citizenList.length, "index out of range");
        delete citizenList[_index];
    }

    function removeOfficial(uint _index) public onlyOwner {
        require(_index >= 0 && _index < officialList.length, "index out of range");
        delete officialList[_index];
    }

    function removeProposalLaw(uint _index) public onlyOwner {
        require(_index >= 0 && _index < lawProposalList.length, "index out of range");
        delete lawProposalList[_index];
    }

    function _setNewOwner(address _newOwner) internal onlyOwner {
        owner = _newOwner;
    }
}