pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract swapNft is Ownable{

    //挂牌记录
    event quotedRecord(address indexed owner, uint8 op, address tokenAddress, uint256 tokenId, uint256 price);//_op：1 质押 0 撤回

    //出售记录
    event saleReocrd(address indexed buy, address sale, address tokenAddress, uint256 tokenId, uint256 price);

    //支持的ERC721合约列表
    mapping (address => uint256) supportERC721TokenList;
    

    //记录TokenId对应的拍卖信息
    struct SaleInfo {
        address payable owner;//持有人
        uint256 price;//价格（SMT）
        uint256 number;//质押块号
    }
    
    //存储所有拍卖信息
    mapping (address => mapping (uint256 => SaleInfo) ) TokenSaleList;
    

    //挂牌交易
    function quoted(address _tokenAddress, uint256 _tokenId, uint256 _price) public {
        
        //是否支持该Token合约交易
        require (supportERC721TokenList[_tokenAddress] > 0);

        //金额不能为空
        require (_price > 0);
        

        //转移Token到合约
        IERC721 ERC721_contract = IERC721(_tokenAddress);
        ERC721_contract.transferFrom(msg.sender, address(this), _tokenId);

        //冗余检测TokenId是否已经到账
        require (ERC721_contract.ownerOf(_tokenId) == address(this));

        //记录挂牌信息
        TokenSaleList[_tokenAddress][_tokenId] = SaleInfo(msg.sender, _price, block.number);
        
        emit quotedRecord(msg.sender, 1, _tokenAddress, _tokenId, _price);

    }

    //撤销挂牌
    function cancel(address _tokenAddress, uint256 _tokenId) public {

        //是否拥有所属权
        require (TokenSaleList[_tokenAddress][_tokenId].owner == msg.sender);
        
        //删除拍卖信息
        delete TokenSaleList[_tokenAddress][_tokenId];
        emit quotedRecord(msg.sender, 0, _tokenAddress, _tokenId, 0);

        //撤回
        IERC721 ERC721_contract = IERC721(_tokenAddress);
        ERC721_contract.transferFrom(address(this), msg.sender, _tokenId);
    }
    
    
    //买下
    function buy(address _tokenAddress, uint256 _tokenId) public payable{

        //是否存在记录
        require (TokenSaleList[_tokenAddress][_tokenId].number > 0);

        //资金是否足够
        require (msg.value >= TokenSaleList[_tokenAddress][_tokenId].price);
        
        //转移Token给购买者
        IERC721 ERC721_contract = IERC721(_tokenAddress);
        ERC721_contract.transferFrom(address(this), msg.sender, _tokenId);

        //转移SMT给挂牌者
        TokenSaleList[_tokenAddress][_tokenId].owner.transfer(msg.value);

        //记录事件
        emit saleReocrd(msg.sender, TokenSaleList[_tokenAddress][_tokenId].owner, _tokenAddress, _tokenId, msg.value);

    }

    //管理员设置Token支持列表
    function addToken(address _tokenAddress, uint256 _status) public onlyOwner {
        supportERC721TokenList[_tokenAddress] = _status;
    }

    //查看Token合约是否在支持列表
    function tokenIsSupport(address _tokenAddress) view public returns(bool res){
        return supportERC721TokenList[_tokenAddress] > 0;
    }

    //查看挂牌Token信息
    function getSaleInfo(address _tokenAddress, uint256 _tokenId) view public returns(address, uint256, uint256) {
        SaleInfo memory info = TokenSaleList[_tokenAddress][_tokenId];
        return (info.owner, info.price, info.number);
    }

}





