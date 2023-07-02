// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Token.sol";
import "./FlashLoan.sol";

contract FlashLoanReceiver{

    FlashLoan private pool;
    address private owner;

    event LoanRecieved(address token, uint256 amount);

    constructor(address _poolAddress){
        pool = FlashLoan(_poolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) external {
        
        require(msg.sender==address(pool), "sender must be pool");

        emit LoanRecieved(_tokenAddress, _amount);

        require(Token(_tokenAddress).transfer(msg.sender, _amount)," transfer of token failed");

    }

    function executeFlashLoan(uint256 _amount) external{
        require(msg.sender==owner, "only owner can execute flash loan");
        pool.flashLoan(_amount);

    }

}