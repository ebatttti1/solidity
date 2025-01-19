// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract MyToken {
    address private tokenOwner;
    uint private tokenInitialBalance;
    uint private tokenTotalSupply;
    uint private tokenDecimals;
    string private tokenName;
    string private tokenSymbol;

    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowances;

    event Transfer(address from, address to, uint amount);
    event Approval(address from, address spender, uint amount);

    constructor (
        uint _initialBalance,
        uint _decimals,
        string memory _name,
        string memory _symbol
    ) {
        tokenInitialBalance = _initialBalance;
        tokenDecimals = _decimals;
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenOwner = msg.sender;
        _mint(tokenInitialBalance * 10**tokenDecimals);
    }

    modifier onlyOwner {
        require(tokenOwner == msg.sender, "only owner can call the function");
        _;
    }

    function _mint(uint _amount) internal onlyOwner {
        balances[msg.sender] += _amount;
        tokenTotalSupply += _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    function _burn(uint _amount) internal onlyOwner {
        require(_amount <= balances[tokenOwner] / 2, "you are not allowed to burn more than half balance");
        balances[msg.sender] -= _amount;
    }

    function transfer(address _to, uint _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "not enough token to transfer");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        require(allowances[_from][msg.sender] >= _amount, "amount is greater than approval token");
        allowances[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "not enough token to approve");
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _from, address _to) public view returns (uint) {
        return allowances[_from][_to];
    }

    function balanceOf(address _account) public view returns(uint) {
        return balances[_account];
    }

    function name() public view returns (string memory) {
        return tokenName;
    }

    function symbol() public view returns(string memory) {
        return tokenSymbol;
    }

    function decimals() public view returns (uint) {
        return tokenDecimals;
    }

    function owner() public view returns (address) {
        return tokenOwner;
    }

    function totalSupply() public view returns(uint) {
        return tokenTotalSupply;
    }
}