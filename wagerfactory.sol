pragma solidity 0.4.24;

import "browser/mouthlink.sol";
import "https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol";

contract WagerCloneFactory is CloneFactory {

    mouthlink ml;

    address public wagerMasterAddress;
    address private clone;

    mapping(address => address) wagers;

    event wagerCreated(address newWagerAddress, address wagerMasterAddress);

    constructor (address _wagerMasterAddress) public {
        wagerMasterAddress = _wagerMasterAddress;
    }

    function createWager(address _challenger) public {
        require(wagers[_challenger] == 0, "challenger exists");
        clone = createClone(wagerMasterAddress);
        wagers[_challenger] = clone;
        mouthlink(wagers[msg.sender]).init(_challenger);
        emit wagerCreated(clone, wagerMasterAddress);
    }

    function createBet(address _challengee, uint248 _priceBet, uint256 _endTime) public payable {
        mouthlink(wagers[msg.sender]).createBet(_challengee, _priceBet, _endTime);
    }

    function fundBet(uint248 _priceBet) public payable {
        mouthlink(wagers[msg.sender]).fundBet(_priceBet);
    }

    function bail() public payable {
        mouthlink(wagers[msg.sender]).bail();
    }

    function returnBetAmount() private view returns (uint256) {
        mouthlink(wagers[msg.sender]).returnBetAmount();
    }

    function returnFunded() public view returns (uint256) {
        mouthlink(wagers[msg.sender]).returnFunded();
    }

    function withdraw() public payable {
        mouthlink(wagers[msg.sender]).withdraw();
    }
}

