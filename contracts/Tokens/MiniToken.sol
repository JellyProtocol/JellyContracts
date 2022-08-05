
pragma solidity 0.8.6;

import "../Access/JellyMinterAccess.sol";
import "../OpenZeppelin/security/Pausable.sol";
import "../Utils/MinimalERC20.sol";


/// @title MINI

contract MiniToken is IJellyContract, ERC20WithSupply, Pausable, JellyMinterAccess {

    string public override symbol;
    string public override name;
    uint8 public constant override decimals = 18;
    uint public cap;

    event CapUpdated(uint256 cap);
    event TokenSet();

    constructor() {
        TEMPLATE_TYPE = 8;
        TEMPLATE_ID = keccak256("MINI_TOKEN");
    }

    /**
     * @dev Pause/unpauses token.
     */
    function setToken() external {
        require(
            hasAdminRole(_msgSender()),
            "MINI.setToken: Sender must be admin"
        );

        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
        
        emit TokenSet();
    }

    /**
     * @dev Sets the hard cap on token supply. 
     */
    function setCap(uint _cap) external  {
        require(
            hasAdminRole(_msgSender()),
            "MINI.setCap: Sender must be admin"
        );
        require( _cap >= totalSupply, "Cap less than totalSupply");
        cap = _cap;
        emit CapUpdated(cap);
    }

    function mint(address to, uint256 amount) public {
        require(hasMinterRole(_msgSender()), "Must have minter role to mint");
        require(to != address(0), "No mint to zero address");
        require(cap >= totalSupply + amount, "Don't go over MAX");
        _mint(to, amount);
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }


    /**
     * @dev Requires hasOperatorRole for token transfers before Mini has been set. 
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (paused()) {
            require(hasOperatorRole(_msgSender()), "Tokens cannot be transferred while paused");
        }
    }

    //--------------------------------------------------------
    // Factory Init
    //--------------------------------------------------------

    /**
     * @notice Initializes main contract variables.
     * @dev Init function.
     * @param _admin Address for the airdrop list.
     * @param _vault Address of the airdrop token.
     * @param _initialSupply Access controls interface.
     * @param _cap Total amount of tokens to distribute.
     */
    
    function initToken(string memory _name, string memory _symbol, address _admin, address _vault, uint256 _initialSupply, uint256 _cap) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        require(_cap == 0 ||  _initialSupply <= _cap, "Initial supply exceeds cap");
        symbol = _symbol;
        name = _name;
        cap = _cap;
        _mint(_vault, _initialSupply);
    }

    /** 
     * @dev Used by the Jelly Factory. 
     */
    function init(bytes calldata _data) external override(IMasterContract,JellyAdminAccess) payable {}

    function initContract(
        bytes calldata _data
    ) public override(IJellyContract,JellyAdminAccess) {
        (
        string memory _name,
        string memory _symbol,
        address _admin,
        address _vault,
        uint256 _initialSupply,
        uint256 _cap
        ) = abi.decode(_data, (string, string, address, address, uint256, uint256));

        initToken(_name,_symbol,  _admin, _vault, _initialSupply, _cap);
    }

    /** 
     * @dev Generates init data for factory. 
     */
    function getInitData(
        string calldata _name,
        string calldata _symbol,
        address _admin,
        address _vault,
        uint256 _initialSupply,
        uint256 _cap
    )
        external
        pure
        returns (bytes memory _data)
    {
        return abi.encode(_name, _symbol, _admin, _vault, _initialSupply, _cap);
    }


}