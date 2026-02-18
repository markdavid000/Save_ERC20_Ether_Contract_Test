// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract SaveERC20_Ether {
    address savingToken;
    address public owner;

    mapping(address => uint256) ERC20savings;
    mapping(address => uint256) public Ethersavings;

    event SavingSuccessful(address sender, uint256 amount);
    event WithdrawSuccessful(address receiver, uint256 amount);

    constructor(address _savingToken) {
        savingToken = _savingToken;
        owner = msg.sender;
    }

    function deposit(uint256 _amount) external {
        require(msg.sender != address(0), "address zero detected");
        require(_amount > 0, "can't save zero value");
        require(IERC20(savingToken).balanceOf(msg.sender) >= _amount, "not enough token");

        require(IERC20(savingToken).transferFrom(msg.sender, address(this), _amount), "failed to transfer");

        ERC20savings[msg.sender] += _amount;

        emit SavingSuccessful(msg.sender, _amount);
    }

    function ERC20Withdraw(uint256 _amount) external {
        require(msg.sender != address(0), "address zero detected");
        require(_amount > 0, "can't withdraw zero value");

        uint256 _userSaving = ERC20savings[msg.sender];

        require(_userSaving >= _amount, "insufficient funds");

        ERC20savings[msg.sender] -= _amount;

        require(IERC20(savingToken).transfer(msg.sender, _amount), "failed to withdraw");

        emit WithdrawSuccessful(msg.sender, _amount);
    }

    function checkUserBalance(address _user) external view returns (uint256) {
        return ERC20savings[_user];
    }

    function checkContractBalance() external view returns(uint256) {
        return IERC20(savingToken).balanceOf(address(this));
    }

    function deposit() external payable {
        // require(msg.sender != address(0), "Address zero detected");
        require(msg.value > 0, "Can't deposit zero value");

        Ethersavings[msg.sender] = Ethersavings[msg.sender] + msg.value;

        emit SavingSuccessful(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");

        // the balance mapping is a key to value pair, if the key is
        // provided it retuns the value at that location.
        //
        uint256 userSavings_ = Ethersavings[msg.sender];

        require(userSavings_ > 0, "Insufficient funds");

        Ethersavings[msg.sender] = userSavings_ - _amount;

        // (bool result,) = msg.sender.call{value: msg.value}("");
        (bool result,) = payable(msg.sender).call{value: _amount}("");

        require(result, "transfer failed");

        emit WithdrawSuccessful(msg.sender, _amount);
    }

    function getUserSavings() external view returns (uint256) {
        return Ethersavings[msg.sender];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
    fallback() external {}
}