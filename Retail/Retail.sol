// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract Retail {
    address owner;
    
    struct Product {
        string name;
        uint price;
        uint stock;
        uint id;
    }
    mapping (uint => Product) products;

    struct Buyer {
        address wallet;
        uint totalPurchasedValue;
        uint lastPurchasedValue;
    }
    mapping (address => Buyer) buyers;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "only owner can call this function");
        _;
    }

    modifier validId(uint _id) {
        require(_id == products[_id].id, "invalid id");
        _;
    }

    function addProduct(string memory _name, uint _price, uint _stock, uint _id) public onlyOwner {
        products[_id] = Product(_name, _price, _stock, _id);
    }

    function updateProductName(uint _id, string memory _newName) public onlyOwner validId(_id) {
        products[_id].name = _newName;
    }

    function updateProductPrice(uint _id, uint _newPrice) public onlyOwner validId(_id) {
        products[_id].price = _newPrice;
    }

    function updateProductStock(uint _id, uint _newStock) public onlyOwner validId(_id) {
        products[_id].stock = _newStock;
    }

    function updateProductId(uint _id, uint _newId) public onlyOwner validId(_id) {
        products[_id].id = _newId;
    }

    function deleteProduct(uint _id) public onlyOwner validId(_id) {
        delete products[_id];
    }

    function purchase(uint _quantity, uint _id) public payable validId(_id) {
        require(_quantity > 0 && _quantity <= products[_id].stock, "out of stock");
        require(msg.value == products[_id].price * _quantity, "value must be equal to product price");
        products[_id].stock -= _quantity;
        buyers[msg.sender].wallet =  msg.sender;
        buyers[msg.sender].lastPurchasedValue = (_quantity * products[_id].price);
        buyers[msg.sender].totalPurchasedValue += (_quantity * products[_id].price);
    }

    function revokePurchase() external {
        require(contractBalance() >= buyers[msg.sender].lastPurchasedValue, "not enough balance to revoke purchase right now");
        require(buyers[msg.sender].lastPurchasedValue > 0, "not purchased");
        payable (msg.sender).transfer(buyers[msg.sender].lastPurchasedValue);
        buyers[msg.sender].lastPurchasedValue = 0;
        buyers[msg.sender].totalPurchasedValue -= buyers[msg.sender].lastPurchasedValue;
    }

    function getProduct(uint _id) public onlyOwner view returns (string memory, uint, uint) {
        return (products[_id].name, products[_id].price, products[_id].stock);
    }

    function getBuyers(address _wallet) public onlyOwner view returns (address, uint, uint) {
        return (buyers[_wallet].wallet, buyers[_wallet].totalPurchasedValue, buyers[_wallet].lastPurchasedValue);
    }
    
    function withdrawAll() external onlyOwner {
        payable (owner).transfer(address(this).balance);
    }

    function withdrawByAmount(uint _amount) external onlyOwner {
        require(_amount <= address(this).balance, "not enough balance to withdraw");
        payable (owner).transfer(_amount);
    }

    function contractOwner() public view returns (address) {
        return owner;
    }

    function contractAddress() public view returns (address) {
        return address(this);
    }

    function contractBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
}