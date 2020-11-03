# PreSale
Source code about deposit of USDT, NFT and pool related to pre-sale.

### deposit_usdt.sol
主要用途是一个erc20 usdt的募资合约，达到融资目标前可以撤出资金，达到后无法撤出。管理员需要在达到目标后才能取走资金。该合约运行在Ethereum公链


### pool.sol
https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v2.3.0/contracts/token/ERC721  获取的标准合约（ERC721_Standard.sol），开发了 pool 合约
主要改动是，新增了对持有合约nft的用户依据持有的区块时间，发放MeshToken奖励。该合约运行在Spectrum公链。


### swap_meshbox.sol
主要用途是让持有smt的用户和持有ERC721合约的nft代币的用户交换资产，管理员注册了指定ERC721合约的交易资格后，该ERC721合约的nft代币即可通过 swap_meshbox 合约进行交换。该合约运行在Spectrum公链



### 关于 swap_meshbox.sol 运行流程的简要说明
1、部署mesh token (https://github.com/MeshBoxFoundation/token/blob/master/MeshBox.sol)， 开启交易权限(调用 enableTransfer方法 )

2、部署erc721，给erc721合约地址转入mesh，并发行erc721币

3、部署swap，把erc721地址加入到swap合约地址支持的交易列表

4、持有erc721中nft的地址，对swap合约开启对应nft的转移授权

5、在swap合约调用挂牌

6、其他地址买入
