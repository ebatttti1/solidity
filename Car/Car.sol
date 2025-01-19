// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract Automotive {
    
    address public owner;
    
    struct Car {
        string carName;
        string carBrand;
        string carColor;
        uint carPrice;
        uint carYear;
        uint carIdNumber;
        address carOwner;
    }
    Car [] public carList;

    struct Buyer {
        string buyerName;
        string buyerPhoneNumber;
        string buyerEmail;
        address buyerAddress;
    }
    Buyer [] public buyerList;

    mapping (uint => bool) public isRegisteredCar;
    mapping (address => bool) public isBuyerByAddress;
    mapping (string => bool) public isBuyerByEmail;

    event Purchase (address seller, address buyer, string carName, uint carYear, uint carIdNumber, uint price);
    event Withdraw(address from, address receiver, uint amount, uint withdrawTime);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "only owner can call this function");
        _;
    }

    modifier checkIsRegisteredCar(uint _idNumber) {
        require(!isRegisteredCar[_idNumber], "this car already registered");
        _;
    }

    modifier checkIsBuyerByAddress(address _buyerAddress) {
        require(!isBuyerByAddress[_buyerAddress], "This buyer by this address is already registered");
        _;
    }

    modifier checkIsBuyerByEmail(string memory _buyerEmail) {
        require(!isBuyerByEmail[_buyerEmail], "This buyer by this address is already registered");
        _;
    }

    function registerCar(string memory _carName, string memory _brand, string memory _color,
    uint _carPrice, uint _carYear, uint _idNumber) public checkIsRegisteredCar(_idNumber) {
        carList.push(Car({
            carName: _carName,
            carBrand: _brand,
            carColor: _color,
            carPrice: _carPrice * 10**18,
            carYear: _carYear,
            carIdNumber: _idNumber,
            carOwner: msg.sender   
        }));
        isRegisteredCar[_idNumber] = true;
    }

    function registerBuyer(string memory _buyerName, string memory _buyerPhoneNumber,
    string memory _buyerEmail) public checkIsBuyerByAddress(msg.sender) checkIsBuyerByEmail(_buyerEmail) {
        require(msg.sender.balance >= 1 ether, "your minimum balance value must be greater than or equal to 1 ETH");
        buyerList.push(Buyer({
            buyerName: _buyerName,
            buyerPhoneNumber: _buyerPhoneNumber,
            buyerEmail: _buyerEmail,
            buyerAddress: msg.sender
        }));
        isBuyerByAddress[msg.sender] = true;
        isBuyerByEmail[_buyerEmail] = true;
    }

    function purchase(uint _index) public payable {
        require(isBuyerByAddress[msg.sender], "You are not registered to purchase");
        require(msg.value == carList[_index].carPrice, "not enough funds to purchase car");
        Car storage car = carList[_index];
        payable (car.carOwner).transfer(car.carPrice * 95 / 100);
        emit Purchase(car.carOwner, msg.sender, car.carName, car.carYear, car.carIdNumber, car.carPrice);
        car.carOwner = msg.sender;
    }

    function withdraw() external payable onlyOwner {
        require(address(this).balance > 0, "contract balance is zero");
        payable (owner).transfer(address(this).balance);
        emit Withdraw(address(this), owner, address(this).balance, block.timestamp);
    }

    function getBuyerInfo(uint _index) public view onlyOwner returns(Buyer memory) {
        require(_index >= 0 && _index < buyerList.length, "index out of range");
        return buyerList[_index];
    }

    function getAllBuyerInfo() public view onlyOwner returns (Buyer [] memory) {
        return buyerList;
    }

    function getCarInfo(uint _index) public view onlyOwner returns(Car memory) {
        require(_index >= 0 && _index < carList.length, "index out of range");
        return carList[_index];
    }

    function getAllCarInfo() public view onlyOwner returns (Car [] memory) {
        return carList;
    }

    function getOwner() public view onlyOwner returns (address) {
        return owner;
    }

    function _setNewOwner(address _newOwner) internal onlyOwner {
        owner = _newOwner;
    }

    function removeCar(uint _index) public onlyOwner {
        require(_index >= 0 && _index < carList.length, "index out of range");
        delete carList[_index];
    }

    function removeBuyer(uint _index) public onlyOwner {
        require(_index >= 0 && _index < buyerList.length, "index out of range");
        delete buyerList[_index];
    }
}