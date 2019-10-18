pragma solidity 0.5.0;

import "./LinkToken.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";

contract Iron is Ownable {

    event balanceLocked(address participant, uint256 balance);

    using Roles for Roles.Role;

    Roles.Role managers;
    Roles.Role holders;

    ERC20 cl = ERC20(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);

    mapping (address => uint) participants;

    function lockBalance(uint256 _balance, uint256 _time) public payable {
        require(
            msg.value > 0,
            "Can't lock empty balance"
            );
        require(
            _time > 0,
            "Epoch can't be current"
            );

            holders.add(msg.sender);
            participants[msg.sender] += msg.value;

    }

    function getLinkBalance(address _address) public view returns (uint256) {
        return cl.balanceOf(_address);
    }

    function checkBalance() public {
        cl.approve(address(this), getLinkBalance(address(this)));
        cl.transferFrom(address(this), msg.sender, getLinkBalance(address(this)));
    }
}
