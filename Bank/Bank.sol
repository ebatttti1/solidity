// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract Bank {
    
    address owner;

    struct Account {
        string fullName;
        string email;
        string phoneNumber;
        uint balance;
        address wallet;
    }
    Account [] accountList;

    mapping (address => uint) balances;
    mapping (address => bool) isUser;

    event CreateAccount(string fullname, string indexed email, string indexed phoneNumber, uint balance, address indexed wallet);
    event Deposit(address indexed from, address indexed to, uint amount, uint depositTime, string description);
    event Withdraw(address indexed from, address indexed to, uint amount, uint withdrawTime, string description);
    event Transfer(address indexed from, address indexed to, uint amount, uint withdrawTime, string description);

    constructor () payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require (owner == msg.sender, "only owner can call the function");
        _;
    }

    function createAccount(string memory _fullName, string memory _email, string memory _phoneNumber) public payable {
        require(!isUser[msg.sender], "this address already registered");
        require(msg.value > 0, "for create account you should give a valid amount to create account");
        accountList.push(Account({
            fullName: _fullName,
            email: _email,
            phoneNumber: _phoneNumber,
            balance: msg.value,
            wallet: payable(msg.sender)
        }));
        balances[msg.sender] += msg.value;
        isUser[msg.sender] = true;
        emit CreateAccount(_fullName, _email, _phoneNumber, msg.value, msg.sender);
    }

    function deposit() external payable { 
        require(msg.value <= msg.sender.balance, "Insufficient funds to deposit");
        require(balances[msg.sender] > 0, "you have no account to deposit funds into");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, address(this), msg.value, block.timestamp, "Deposit");
    }

    function withdraw(uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient funds in your account");
        payable (msg.sender).transfer(_amount);
        balances[msg.sender] -= _amount;
        emit Withdraw(address(this), msg.sender, _amount, block.timestamp, "Withdraw");
    }

    function transfer(address _to, uint _amount) external {
        require(isUser[_to], "address to not found");
        require(_amount > 0 && _amount <= balances[msg.sender], "invalid amount");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount, block.timestamp, "Transfer");
    }

    function removeAccount(uint _index) public onlyOwner {
        require(_index >= 0 && _index < accountList.length, "index out of range");
        delete accountList[_index];
    }

    function addressOwner() public view returns (address) {
        return owner;
    }

    function addressContract() public view returns (address) {
        return address(this);
    }

    function getBalanceForOwner(address _user) public view onlyOwner returns (uint){
        return balances[_user];
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function accountInfoForOwner(uint _index) public view onlyOwner returns (Account memory) {
        require(_index >= 0 && _index < accountList.length, "index out of range");
        return accountList[_index];
    }

    function allAccountInfoForOwner() public view onlyOwner returns (Account [] memory) {
        return accountList;
    }

    function _setNewOwner(address _newOwner) internal onlyOwner {
        owner = _newOwner;
    }
}