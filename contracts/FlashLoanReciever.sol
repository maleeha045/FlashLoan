// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./FlashLoan.sol";
import "./Token.sol";

contract FlashLoanReciever {
    FlashLoan private pool;
    address private owner;

    event LoanRecieved(address tokenAddress, uint256 amount);

    constructor(address _poolAddress) {
        owner = msg.sender;
        pool = FlashLoan(_poolAddress);
    }

    function recieveTokens(address _tokenAddress, uint _amount) external {
        require(msg.sender == address(pool), "sender must be pool");

        // ensure funds recieved
        require(
            Token(_tokenAddress).balanceOf(address(this)) == _amount,
            "failed to recieve tokens"
        );

        // emit event
        emit LoanRecieved(_tokenAddress, _amount);

        // do stuff with the money

        // pay back the loan
        require(
            Token(_tokenAddress).transfer(msg.sender, _amount),
            "transfer of tokens failed"
        );
    }

    function executeFlashLoan(uint _amount) external {
        require(msg.sender == owner, "you are not owner");
        pool.flashLoan(_amount);
    }
}
