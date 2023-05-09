// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISymbol {
    struct Round {
        uint timestamp;
        uint price;
    }

    function digits() external view returns(uint8 _digits);
    function name() external view returns(string memory _name);

    function getLastPrice() external view returns(uint roundId, uint timestamp, uint price);
    function getHistoryPrice(uint roundId) external view returns(uint timestamp, uint price);
    function getBatchHistoryPrice(uint roundId, uint maxRounds) external view returns (Round[] memory rounds, uint total);
 
    function roundAdd(uint roundId, uint timestamp, uint price) external;
}