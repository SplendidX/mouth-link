pragma solidity 0.4.24;

import { Math } from "browser/math.sol";
import "https://github.com/smartcontractkit/chainlink/blob/master/examples/testnet/contracts/TestnetConsumer.sol";

contract mouthlink is ChainlinkClient {

    uint256 constant private ORACLE_PAYMENT = 1 * LINK;
    bytes32 constant UINT256_MUL_JOB = bytes32("6d1bfe27e7034b1d87b5270556b17277");

    address public challenger;
    address public challengee;
    uint248 challengerPriceBet;
    uint248 challengeePriceBet;
    uint256 betAmount;
    uint256 endTime;
    uint248 public currentPrice;
    //uint248 public testPrice = 1000;

    mapping(address => uint256) balance;

    modifier onlyChallengers() {
        require(msg.sender == challenger || msg.sender == challengee, "Caller isn't the challenger or challengee");
        _;
    }

    constructor() public {
        //setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        //setChainlinkOracle(0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e);
    }

    function init(address _challenger) public {
        require(challenger == address(0));
        require(_challenger != address(0));
        challenger = _challenger;
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        setChainlinkOracle(0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e);
    }

    function requestPrice() private onlyChallengers {
        Chainlink.Request memory req = buildChainlinkRequest(UINT256_MUL_JOB, this, this.fulfill.selector);
        req.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
        req.add("path", "USD");
        req.addInt("times", 100);
        sendChainlinkRequest(req, ORACLE_PAYMENT);
    }

    function fulfill(bytes32 _requestId, uint248 _price) public recordChainlinkFulfillment(_requestId) {
        currentPrice = _price;
    }

    function createBet(address _challengee, uint248 _priceBet, uint256 _endTime) public payable {
        require(msg.sender == challenger && msg.value > 0);
        challengee              = _challengee;
        challengerPriceBet      = _priceBet;
        betAmount               = msg.value;
        balance[msg.sender]     += msg.value;
        endTime                 = now + _endTime;
    }

    function fundBet(uint248 _priceBet) public payable {
        require(msg.sender == challengee && msg.value == betAmount);
        challengeePriceBet = _priceBet;
        balance[msg.sender] += msg.value;
    }

    function bail() public payable {
        require(msg.sender == challenger && balance[challengee] == 0);
        challenger.transfer(address(this).balance);
    }

    function returnBetAmount() public view returns (uint256) {
        return betAmount;
    }

    function returnFunded() public view returns (uint256) {
        return balance[msg.sender];
    }

    function checkClosest(int a, int b) public view returns (int) {
        int challengerPriceBetAbs = Math.abs(a - currentPrice) * 100;
        int challengeePriceBetAbs = Math.abs(b - currentPrice) * 100;
        return (challengerPriceBetAbs == challengeePriceBetAbs ? 0 : (challengerPriceBetAbs < challengeePriceBetAbs ? a : b));
    }

    function withdraw() public payable onlyChallengers {
        require(now > endTime, "Bet time hasn't reached");
        if (currentPrice == 0) { requestPrice();
        } else { if (checkClosest(challengerPriceBet, challengeePriceBet) == challengerPriceBet) {
                challenger.transfer(address(this).balance);
            } else { challengee.transfer(address(this).balance); }
        }
    }
}

