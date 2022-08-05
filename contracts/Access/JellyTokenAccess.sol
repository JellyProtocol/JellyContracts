pragma solidity 0.8.6;

import "./JellyMinterAccess.sol";


contract JellyTokenAccess is JellyMinterAccess {
    /// @notice Role definitions
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Events for adding and removing various roles

    event PauserRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event PauserRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    constructor()  {
    }

    /////////////
    // Lookups //
    /////////////

    /**
     * @notice Used to check whether an address has the minter role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasPauserRole(address _address) public view returns (bool) {
        return hasRole(PAUSER_ROLE, _address);
    }


    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @notice Grants the minter role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addPauserRole(address _address) external {
        grantRole(PAUSER_ROLE, _address);
        emit PauserRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the minter role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removePauserRole(address _address) external {
        revokeRole(PAUSER_ROLE, _address);
        emit PauserRoleRemoved(_address, _msgSender());
    }


}
