// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISymbol.sol";

contract PriceOracle is Ownable {
    mapping(uint=>address) s_symbols;

    event SymbolAdded(uint indexed symbolCode, address symbol);
    event SymbolUpdated(uint indexed symbolCode, address symbolOld, address symbolNew);
    event SymbolDeleted(uint indexed symbolCode);

    modifier symbolExist(uint symbolCode) {
        require(s_symbols[symbolCode]!=address(0),"wrong symbol code");
        _;
    }

    /// @notice Proxies to aggregators functions
    function symbolDigits(uint symbolCode) public view symbolExist(symbolCode) returns(uint8) {
        return ISymbol(s_symbols[symbolCode]).digits();
    }

    function symbolName(uint symbolCode) public view symbolExist(symbolCode) returns(string memory) {
        return ISymbol(s_symbols[symbolCode]).name();
    }

    function getLastPrice(uint symbolCode) public view symbolExist(symbolCode) returns(uint roundId, uint timestamp, uint price) {
        (roundId, timestamp, price) = ISymbol(s_symbols[symbolCode]).getLastPrice();
    }

    function getHistoryPrice(uint symbolCode, uint roundId) public view symbolExist(symbolCode) returns(uint timestamp, uint price) {
        (timestamp, price) = ISymbol(s_symbols[symbolCode]).getHistoryPrice(roundId);
    }

    function getBatchHistoryPrice(uint symbolCode, uint roundId, uint maxRounds) public view returns (ISymbol.Round[] memory prices, uint total) {
        (prices, total) = ISymbol(s_symbols[symbolCode]).getBatchHistoryPrice(roundId, maxRounds);
    }


    /// @notice Owner only, manipulating for set of aggregators
    function symbolAddOrUpdate(uint symbolCode, address symbol) public onlyOwner {
        require(symbol!=address(0), "zero address");

        if(s_symbols[symbolCode]==address(0)) {
            s_symbols[symbolCode]=symbol;

            emit SymbolAdded(symbolCode, symbol);
        }
        else {
            address _oldSymbol=s_symbols[symbolCode];
            s_symbols[symbolCode]=symbol;

            emit SymbolUpdated(symbolCode, _oldSymbol, symbol);
        }
    }

    function symbolDelete(uint symbolCode) public onlyOwner symbolExist(symbolCode) {
        delete s_symbols[symbolCode];

        emit SymbolDeleted(symbolCode);
    }
}