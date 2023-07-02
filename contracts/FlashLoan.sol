// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}



contract FlashLoan {
    using SafeMath for uint256;

    Token public token1;
    uint256 public poolBalance;

    constructor(address _tokenAddress)  {
        require(_tokenAddress!=address(0),"token address cannot be zero !");
        token1 = Token(_tokenAddress);
    }

    function depositTokens(uint256 _amount) external {
        require(_amount>0," must deposit at least one token ");
        token1.transferFrom(msg.sender,address(this), _amount);
        poolBalance = poolBalance.add(_amount);
    }

    function flashLoan(uint256 _borrowAmount) external{
        require(_borrowAmount>0,"must borrow atleast one token");

        uint256 balanceBefore = token1.balanceOf(address(this));
        require(balanceBefore>=_borrowAmount,"not have enough tokens in pool");

        // ensured by the protocol via the "depositTokens" function
        assert(poolBalance==balanceBefore);

        // send tokens to reciever
        token1.transfer(msg.sender, _borrowAmount);

        // get paid back
        IReceiver(msg.sender).receiveTokens(address(token1),_borrowAmount);

        // ensure loan is paid back
        uint256 balanceAfter = token1.balanceOf(address(this));
        // require(balanceAfter >= balanceBefore, "flash loan hasn't been paid back!");
        
            
        }    
    
}