# PreSale:
Source code about deposit of USDT, NFT and pool related to pre-sale.

#### deposit_usdt.sol
The main purpose is to use an erc20 USDT fund-raising contract. The fund can be withdrawn before the financing target is reached, but cannot be withdrawn after reaching the financing target. Administrators need to reach their goals before they can take it. The contract runs on Ethereum.

#### pool.sol
From [erc721_ Standard.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v2.3.0/contracts/token/ERC721) standard contract obtained, developed the pool contract.
The main change is to add MESH token rewards to users who hold contract NFT according to the block time they hold. The contract runs on Spectrum. 

#### swap_meshbox.sol
The main purpose is to exchange assets between users holding SMT and NFT tokens of erc721 contract. After the administrator registers the transaction qualification of the specified erc721 contract, the NFT token of the erc721 contract can pass the swap_ Meshbox contracts are exchanged. The contract runs on Spectrum.

#### About swap_ meshbox.sol description of operation process
1.Deploy [MESH](https://spectrum.pub/token.html?source=commonts&tokenF=0xa4c9af589c07b7539e5fcc45975b995a45e3f379), enable transaction permission (call the enabletransfer method)

2.Deploy erc721, transfer erc721 contract address to mesh, and issue erc721 currency

3.Deploy swap and add erc721 address to the transaction list supported by swap contract address

4.Hold the wallet address of NFT in erc721 and enable the transfer authorization of NFT corresponding to the swap contract

5.Listing in swap contract call

6.Buy at other wallet address
