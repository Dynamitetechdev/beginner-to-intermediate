// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./context/context.sol";

error BQtoken_cannotBeTheZeroAddress();
error BQtoken_NotEnoughBalance();
error BQtoken_NotEnoughBalancce();

contract BQtoken is Context {
    string private _name;
    string private _symbol;
    uint private _totalSupply;
    uint32 constant DECIMALS = 18;
    uint256 private ownerMintToken = 500000 * 10 ** 18;

    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _value
    );
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 indexed _value
    );
    event tokenMinted(address indexed Account, uint indexed AmountedMinted);

    constructor() {
        _name = "BeuniQue";
        _symbol = "BQT";

        _mint(Owner(), ownerMintToken);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint) {
        return DECIMALS;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balanceOf[_owner];
    }

    function ownerAddress() public view returns (address) {
        return Owner();
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        address owner = Owner();
        _approve(owner, _spender, _value);
        return true;
    }

    /* 
    1. the owner and spender should not be the zero address
    2. check if the owner has more than the approved funds
    3. update the allowance of the spender
    */

    function _approve(address owner, address spender, uint amount) internal {
        if (owner == address(0)) revert BQtoken_cannotBeTheZeroAddress();
        if (spender == address(0)) revert BQtoken_cannotBeTheZeroAddress();
        if (_balanceOf[owner] <= amount) revert BQtoken_NotEnoughBalance();
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return _allowance[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address owner = Owner();
        _transfer(owner, _to, _value);
        return true;
    }

    /* 
    1. the owner and to cant be the zero address
    2. check if the owner have enough to transfer
    3. subtract from the amount from the owner balance
    4. Add the amount to to TO balance
    */
    function _transfer(address _owner, address _to, uint amount) internal {
        if (_owner == address(0)) revert BQtoken_cannotBeTheZeroAddress();
        if (_to == address(0)) revert BQtoken_cannotBeTheZeroAddress();

        uint ownerBalance = _balanceOf[_owner];
        if (ownerBalance <= amount) revert BQtoken_NotEnoughBalance();
        _balanceOf[_owner] = ownerBalance - amount;
        _balanceOf[_to] += amount;

        emit Transfer(_owner, _to, amount);
    }

    /* 
    1. Check if the owner is enough to transfer to the spender
    2. Address cannot be the zero address. already in the _transfer logic
    3. check if the current allowance is enough to transferFrom
    4. we transfer using the _transfer logic 
    5. and we will also update Approve using the _approve logic and subtract the Value from the spenders approved funds
    */
    function transferFrom(
        address _owner,
        address _spender,
        uint256 _value
    ) public returns (bool) {
        address spender = Owner();
        _spendAllowance(_owner, spender, _value);
        _transfer(_owner, _spender, _value);
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal {
        uint currentAllowance = _allowance[owner][spender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance <= value) revert BQtoken_NotEnoughBalancce();
            _approve(owner, spender, currentAllowance - value);
        }
    }

    /* 
    1. make sure the accountMinting is the msg.sender
    2. the account must not be the zero address
    3. add the amount minted to our total supply
    4. add the amount minted to the senders address
    5. emit event
    
    */
    function _mint(address account, uint amount) private {
        account = Owner();
        if (account == address(0)) revert BQtoken_cannotBeTheZeroAddress();
        _totalSupply += amount;
        _balanceOf[account] += amount;
        emit tokenMinted(account, amount);
    }
}
