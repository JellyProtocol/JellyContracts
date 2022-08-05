pragma solidity 0.8.6;

import "../../interfaces/IJellyFactory.sol";
import "../../interfaces/IJellyContract.sol";
import "../../interfaces/IJellyAccessControls.sol";
import "../OpenZeppelin/token/ERC20/utils/SafeERC20.sol";
import "../OpenZeppelin/utils/math/SafeMath.sol";

contract MiniTokenRecipe {

    using SafeMath for uint256;
    using SafeERC20 for OZIERC20;

    IJellyFactory public jellyFactory;
    uint256 public feePercentage; 
    address jellyVault;
    bool public locked;

    /// @notice Address that manages approvals.
    IJellyAccessControls public accessControls;

    /// @notice Jelly template id for the pool factory.
    uint256 public constant TEMPLATE_TYPE = 4;
    bytes32 public constant TEMPLATE_ID = keccak256("MINI_TOKEN_RECIPE");

    bytes32 public constant TOKEN_ID = keccak256("MINI_TOKEN");

    event MiniTokenDeployed(address indexed token, address admin, uint256 cap);
    event Recovered(address indexed token, uint256 amount);

    /** 
     * @notice Mini Token Recipe
     * @param _jellyFactory - A factory that makes fresh Jelly
    */
    constructor(
        address _accessControls,
        address _jellyFactory,
        address _jellyVault,
        uint256 _feePercentage
    ) {
        require(_feePercentage < 10000, "Fee percentage too high");
        accessControls = IJellyAccessControls(_accessControls);
        jellyFactory = IJellyFactory(_jellyFactory);
        jellyVault = _jellyVault;
        feePercentage = _feePercentage;
        locked = true;
    }

    /**
     * @notice Sets the recipe to be locked or unlocked.
     * @param _locked bool.
     */
    function setLocked(bool _locked) external {
        require(
            accessControls.hasAdminRole(msg.sender),
            "setLocked: Sender must be admin"
        );
        locked = _locked;
    }

    /**
     * @notice Sets the vault address.
     * @param _vault Jelly Vault address.
     */
    function setVault(address _vault) external {
        require(accessControls.hasAdminRole(msg.sender), "setVault: Sender must be admin");
        require(_vault != address(0));
        jellyVault = _vault;
    }

    /**
     * @notice Sets the access controls address.
     * @param _accessControls Access controls address.
     */
    function setAccessControls(address _accessControls) external {
        require(accessControls.hasAdminRole(msg.sender), "setAccessControls: Sender must be admin");
        require(_accessControls != address(0));
        accessControls = IJellyAccessControls(_accessControls);
    }

    /**
     * @notice Sets the current fee percentage to deploy.
     * @param _feePercentage The fee percentage to 2 decimals, 2.5% = 250
     */
    function setFeePercentage(uint256 _feePercentage) external {
        require(
            accessControls.hasAdminRole(msg.sender),
            "setFeePercentage: Sender must be admin"
        );
        require(_feePercentage < 10000, "Fee percentage too high");
        feePercentage = _feePercentage;
    }


    /** 
     * @dev prepare Mini Token recipe
     *   
    */
    function prepareMiniToken(
        string calldata _name,
        string calldata _symbol,
        address _tokenAdmin,
        address _initialTokenDestination,
        uint256 _initialSupply

    )
        external
        returns (address)
    {
        require(_tokenAdmin != address(0), "Admin address not set");
        require(_initialTokenDestination != address(0), "Token destination not set");
 
        /// @dev If the contract is locked, only admin and minters can deploy. 
        if (locked) {
            require(accessControls.hasAdminRole(msg.sender) 
                    || accessControls.hasMinterRole(msg.sender),
                "prepareJellyFarm: Sender must be minter if locked"
            );
        }

        address mini_token = jellyFactory.deployContract(
            TOKEN_ID,
            payable(jellyVault), 
            "");

        IJellyContract(mini_token).initContract(abi.encode(_name, _symbol, _tokenAdmin, _initialTokenDestination, _initialSupply, _initialSupply)); 

        emit MiniTokenDeployed(mini_token, _tokenAdmin, _initialSupply);
        return mini_token;
    }

    receive() external payable {
        revert();
    }


    /// @notice allows for the recovery of incorrect ERC20 tokens sent to contract
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "recoverERC20: Sender must be admin"
        );
        // OZIERRC20 uses SafeERC20.sol, which hasn't overriden `transfer` method of OZIERC20. Shifting to `safeTransfer` may help
        OZIERC20(tokenAddress).transfer(jellyVault, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

}