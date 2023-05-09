# Smart-contracts and transmitters configuration

## Deployed smart-contracts addresses
```
PriceOracle contract : 0xBf077822a20dECE7A03d0489c1d601790F1152bF

#0, GOLD:
        symbol       : 0xecaEdad63958346F77F1d91a7D680EbCDC550513
        aggregator   : 0x9d0d6969A4dc04BDff325a28e7E24cbf5aF28A12
#1, BRENT:
        symbol       : 0x6764bd887a53037B94404A2d58932a6DE6aE664b
        aggregator   : 0xF7775Ca40d75D5e1815E5cDA9648c3CF0f91D155
#2, USDKZT:
        symbol       : 0x619359a818566a237d687A28d14f4f9aE4f2D319
        aggregator   : 0xDc62Ba25684d68eb0215cb328FD5BcC013fFB1F8
```

## Host #1 accounts

```
transmitter GOLD   : 0xaaaaa1c6c7607f000e6cd9a5f6aa94c4e4c2496b
transmitter BRENT  : 0xbbbbb7009e85eb381e5e4935f9f137f76f546a8b
transmitter USDKZT : 0xcccccc1c8504ee2e7a0c14ddc9ee56de3d5ef273
heartbit           : 0xdddddce1ca5b48fe247500c6e12bacc0db4b3b5a
```

## Host #2 accounts

```
transmitter GOLD   : 0xaaaaae23c5d243573d919d43e2fe114670b2f5a3
transmitter BRENT  : 0xbbbbb8a5d9ac0113c9152ae20981b3ddef9cf4f0
transmitter USDKZT : 0xccccc4f79e73179abd196f7adc3f2cc9af7c25d6
```

## Some Hardhat scripts calls (for myself)

```
hh transmitterAdd --aggregator 0x9d0d6969A4dc04BDff325a28e7E24cbf5aF28A12 --transmitter "0xaaaaa1c6c7607f000e6cd9a5f6aa94c4e4c2496b,0xaaaaae23c5d243573d919d43e2fe114670b2f5a3" --network bnbt
hh transmitterAdd --aggregator 0xF7775Ca40d75D5e1815E5cDA9648c3CF0f91D155 --transmitter "0xbbbbb7009e85eb381e5e4935f9f137f76f546a8b,0xbbbbb8a5d9ac0113c9152ae20981b3ddef9cf4f0" --network bnbt
hh transmitterAdd --aggregator 0xDc62Ba25684d68eb0215cb328FD5BcC013fFB1F8 --transmitter "0xcccccc1c8504ee2e7a0c14ddc9ee56de3d5ef273,0xccccc4f79e73179abd196f7adc3f2cc9af7c25d6" --network bnbt
```