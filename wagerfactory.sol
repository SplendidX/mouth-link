pragma solidity 0.4.24;

import "browser/mouthlink.sol";
import "https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol";

contract WagerCloneFactory is CloneFactory {

    mouthlink ml;

    address public wagerMasterAddress;
    address private clone;
    address[] public createdWagers;

    mapping(address => address) wagers;

    event wagerCreated(address newWagerAddress);

    constructor (address _wagerMasterAddress) public {
        wagerMasterAddress = _wagerMasterAddress;
    }

    function getContractAddressAtIndex() public constant returns (address) {
        if (createdWagers.length == 0) { return createdWagers[0];
        } else { return createdWagers[createdWagers.length-1]; }
    }

    function getCreatedWagers() public constant returns (address[]) {
        return createdWagers;
    }

    function createWager(address _challenger) public {
        clone = createClone(wagerMasterAddress);
        wagers[_challenger] = clone;
        mouthlink(wagers[msg.sender]).init(_challenger);
        createdWagers.push(clone);
        emit wagerCreated(clone);
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

    function returnBetAmount() public view returns (uint256) {
        mouthlink(wagers[msg.sender]).returnBetAmount();
    }

    function returnFunded() public view returns (uint256) {
        mouthlink(wagers[msg.sender]).returnFunded();
    }

    function returnCurrentPrice() public view returns (uint248) {
        mouthlink(wagers[msg.sender]).returnCurrentPrice();
    }

    function withdraw() public payable {
        mouthlink(wagers[msg.sender]).withdraw();
    }
}

