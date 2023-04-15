// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReciever {
    function recieveTokens(address tokenAddress, uint amount) external;
}

contract FlashLoan is ReentrancyGuard {
    using SafeMath for uint256;

    Token public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    function depositTokens(uint _amount) external nonReentrant {
        require(_amount > 0, "must deposit at least one token");
        token.transferFrom(msg.sender, address(this), _amount);
        poolBalance = poolBalance.add(_amount);
    }

    function flashLoan(uint _borrowAmount) external nonReentrant {
        require(_borrowAmount > 0, "must borrow at least 1 token");
        uint balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= _borrowAmount, "not enough tokens");

        // ensured by the protocol via 'depositTokens' function
        assert(poolBalance == balanceBefore);

        // sends token to reciever
        token.transfer(msg.sender, _borrowAmount);
        // use loan, get paid back
        IReciever(msg.sender).recieveTokens(address(token), _borrowAmount);

        // ensure loan paid back
        uint balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= _borrowAmount, "not enough tokens");
    }
}
