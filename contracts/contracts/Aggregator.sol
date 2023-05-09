// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISymbol.sol";

contract Aggregator is Ownable {
    struct Deviation {
        uint16  value;
        uint16  denominator;
    }

    uint                    s_counter;
    uint                    s_currentRound;
    address                 s_heartbit;
    address                 s_symbol;
    mapping(address=>bool)  s_transmitters;
    Deviation               s_maxDeviation;
    uint                    s_minSigners;
    uint constant           MAX_DELAY = 30 seconds;
    // round data
    uint                    s_prevRoundPrice;
    uint                    s_startedAt;
    uint[]                  s_prices;
    address[]               s_signers;

    event Round(uint roundId, uint startedAt);

    /// @dev default minSigners = 2
    constructor(address heartbit, uint minSigners) {
        require(heartbit!=address(0), "zero heartbit address");
        require(minSigners>0, "zero min signers");

        s_heartbit=heartbit;
        s_counter=1;
        s_minSigners=minSigners;
        s_prevRoundPrice=0;

        // we request price rarely, let's use 10% max price deviation by default
        s_maxDeviation.value=10;
        s_maxDeviation.denominator=100;
    }

    modifier onlyHeartbit() {
        require(msg.sender==s_heartbit,"wrong tx initiator");
        _;
    }

    /// @notice Called by heartbit
    function startRound() public onlyHeartbit {
        require(s_currentRound==0,"round in progress");

        s_currentRound=s_counter;
        s_counter++;
        s_startedAt=block.timestamp;

        emit Round(s_currentRound, s_startedAt);
    }

    /// @notice Called by transmitters
    function transmit(uint roundId, uint timestamp, uint price, uint8 v, bytes32 r, bytes32 s) public {
        // check round started and not stopped
        require(s_currentRound!=0,"round not in progress");
        
        // check price and block timestamps
        require(timestamp      <=s_startedAt+MAX_DELAY,"outdated price (transmitter)");
        require(block.timestamp<=s_startedAt+MAX_DELAY,"outdated price (network)");
        
        // check price deviation
        if(s_prevRoundPrice>0) {
            uint _maxDeviation= (s_prevRoundPrice*s_maxDeviation.value)/s_maxDeviation.denominator;
            uint _deviation   = s_prevRoundPrice>price?(s_prevRoundPrice-price):(price-s_prevRoundPrice);
            require(_deviation<_maxDeviation,"too high price deviation");
        }

        // check transmitter authorized
        bytes32 payloadHash = keccak256(abi.encode(roundId, timestamp, price));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payloadHash));
        address signer      = ecrecover(messageHash, v, r, s);

        require(s_transmitters[signer],"transmitter not authorized to submit prices");

        // do not allow transmitter send prices multiple times to avoid avg.price spoofing
        require(!isSignedRound(signer),"transmitter can submit price only once");
        s_signers.push(signer);
        
        // all checks passed, store price
        s_prices.push(price);
    }

    /// @notice Called by heartbit
    /// @dev    Even no symbol set, no prices collected we must force closing round
    function stopRound() external onlyHeartbit {
        // check symbol is set
        if(s_symbol!=address(0)) {
            // check prices collected
            uint _numPrices=s_prices.length;
            if(s_minSigners>0 && _numPrices>=s_minSigners) {
                // calc average price
                uint _averagePrice;
                for(uint i=0; i<_numPrices; i++) {
                    _averagePrice+=s_prices[i];
                }
                _averagePrice=_averagePrice/_numPrices;
                
                // check average price not equals price from previous round
                if(_averagePrice!=s_prevRoundPrice) {
                    // submit price to symbol
                    ISymbol(s_symbol).roundAdd(s_currentRound,s_startedAt,_averagePrice);
                }
            }
        }

        // reset round state
        s_currentRound=0;
        s_startedAt=0;
        delete s_prices;
        delete s_signers;
    }

    function isSignedRound(address signer) internal view returns(bool) {
        uint _numSigners=s_signers.length;
        for(uint i=0;i<_numSigners;i++) {
            if(s_signers[i]==signer) {
                return true;
            }
        }

        return false;
    }

    /// @notice Administrative functions
    function setHeartbit(address heartbit) public onlyOwner {
        require(heartbit!=address(0), "zero address");

        s_heartbit=heartbit;
    }

    function setSymbol(address symbol) public onlyOwner {
        require(symbol!=address(0), "zero address");

        s_symbol=symbol;
    }

    function transmitterAdd(address transmitter) public onlyOwner {
        require(transmitter!=address(0), "zero address");

        s_transmitters[transmitter]=true;
    }

    function transmitterDelete(address transmitter) public onlyOwner {
        require(transmitter!=address(0), "zero address");

        if(s_transmitters[transmitter]) {
            delete s_transmitters[transmitter];
        }
    }

    function setMaxPriceDeviation(uint16 value, uint16 denominator) public onlyOwner {
        require(value>1 && denominator>1,"wrong values");

        s_maxDeviation.value      =value;
        s_maxDeviation.denominator=denominator;
    }

    function setMinSigners(uint minSigners) public onlyOwner {
        require(minSigners>0,"zero value");
        s_minSigners=minSigners;
    }
}