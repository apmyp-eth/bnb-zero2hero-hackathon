// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISymbol.sol";

contract Symbol is ISymbol, Ownable {
    address                 s_aggregator;
    uint8                   s_digits;
    string                  s_name;
    mapping(uint=>Round)    s_rounds;
    uint                    s_last_round_id;

    event PriceUpdated(uint createdAt, uint updatedAt, uint price);

    constructor(string memory _name, uint8 _digits, address _aggregator) {
        require(_aggregator!=address(0), "zero address");

        s_name = _name;
        s_digits = _digits;
        s_aggregator = _aggregator;
    }

    /// @notice Interface functions for datafeed contract
    function digits() public view override returns(uint8) {
        return s_digits;
    }

    function name() public view override returns(string memory) {
        return s_name;
    }

    function getLastPrice() public view override returns(uint, uint, uint) {
        // may be not initialized yet or something went wrong
        require(s_rounds[s_last_round_id].timestamp>0, "no prices");

        Round storage round=s_rounds[s_last_round_id];
        return (s_last_round_id, round.timestamp, round.price);
    }

    function getHistoryPrice(uint roundId) public view override returns(uint, uint) {
        require(s_rounds[roundId].timestamp>0, "round not exist");

        Round storage round=s_rounds[roundId];
        return (round.timestamp, round.price);
    }

    function getBatchHistoryPrice(uint roundId, uint maxRounds) public view override returns (Round[] memory rounds, uint total) {
        require(maxRounds<=100, "max rounds should be less than 101");
        require(roundId<=s_last_round_id,"wrong round id");

        rounds = new Round[](maxRounds);

        total=0;
        for(uint i=roundId; i>0 && total<maxRounds; i--) {
            Round storage round=s_rounds[i];
            if(round.timestamp>0) {
                rounds[total++]=round;
            }
        }
    }

    /// @notice Internal mechanics
    function setAggregator(address _aggregator) public onlyOwner {
        s_aggregator = _aggregator;
    }

    function setName(string calldata _name) public onlyOwner {
        s_name = _name;
    }

    function roundAdd(uint roundId, uint timestamp, uint price) public {
        require(msg.sender==s_aggregator, "not authorized");
        require(s_rounds[roundId].timestamp==0, "round already exist");

        s_rounds[roundId]=Round(timestamp, price);
        s_last_round_id=roundId;

        emit PriceUpdated(timestamp, block.timestamp, price);
    }
}