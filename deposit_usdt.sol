pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract mortgage is Ownable{


	//质押事件
	event Deposit(address indexed _addr);

	//撤销事件
	event Cancel(address indexed _addr);

	//质押地址和质押次数的映射
	mapping (address => uint256) userMap;

	//USDT合约地址
	address usdtTokenAddress;

	//每次质押金额
	uint256 depositValue;

	//目标用户数，超过该数量不可撤销，也不可再接收募资
	uint256 targetUserNum;

	//质押用户总数
	uint256 totalUserNum;

	constructor(address _addr, uint256 _value, uint256 _num) public {
		usdtTokenAddress = _addr;
		depositValue = _value;
		targetUserNum = _num;
		totalUserNum = 0;
    }


    //用户存款
	function deposit() public {

		//不能超过募集目标
		require (totalUserNum < targetUserNum);
		
		IERC20 usdt_contract = IERC20(usdtTokenAddress);

		//查询当前余额
		uint256 beforeValue = usdt_contract.balanceOf(address(this));

		//取款（对方余额不足时usdt合约将会触发revert）
		usdt_contract.transferFrom(msg.sender, address(this), depositValue);

		//冗余检测资金是否到账
		require (usdt_contract.balanceOf(address(this)) > beforeValue);
		
		//修改状态并记录事件
		userMap[msg.sender] = userMap[msg.sender] + 1;
		totalUserNum++;
		emit Deposit(msg.sender);
	}


	//用户撤销
	function cancel() public {
		
		//是否质押
		require (userMap[msg.sender] > 0);

		//达到募集目标后无法退款
		require (totalUserNum < targetUserNum);

		//更新状态并记录事件
		userMap[msg.sender] = userMap[msg.sender] - 1;
		totalUserNum--;
		emit Cancel(msg.sender);

		//打款
		IERC20 usdt_contract = IERC20(usdtTokenAddress);
		usdt_contract.transfer(msg.sender, depositValue);
	}
	

	//管理员提款
	function withdraw(address _to) public onlyOwner {
		
		//必须达到募集目标
		require(totalUserNum == targetUserNum);

        IERC20 usdt_contract = IERC20(usdtTokenAddress);

		//打款
		uint256 total = usdt_contract.balanceOf(address(this));
		
		usdt_contract.transfer(_to, total);
	}


    //获取当前质押用户总数
	function getTotalUserNum() view public returns(uint256) {
		return totalUserNum;
	}

    //获取质押金额
    function getDepositValue() view public returns(uint256) {
        return depositValue;
    }

    //获取usdt合约地址
    function getUsdtTokenAddress() view public returns(address) {
        return usdtTokenAddress;
    }

    //获取目标用户数
    function getTargetUserNum() view public returns(uint256) {
        return targetUserNum;
    }

    //获取质押次数
    function getDepositNum(address _addr) view public returns(uint256) {
        return userMap[_addr];
    }    

}
