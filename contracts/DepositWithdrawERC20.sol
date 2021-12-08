// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";

contract DepositWitdrawERC20  {
    address owner;
    mapping(address => uint) public tokensBalance;


    constructor() {
        owner = msg.sender;
    }
    modifier isOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function deposit(address _token, uint _amount) external isOwner{
        require(_amount > 0, 'Amount most be positive');
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        tokensBalance[_token] += _amount;
    }


    function withdraw(address _token, uint _amount) external isOwner {
        require(tokensBalance[_token] >= _amount, 'Amount exceed balance' );
        IERC20(_token).transfer(msg.sender, _amount);
        tokensBalance[_token] -= _amount;
    }
}