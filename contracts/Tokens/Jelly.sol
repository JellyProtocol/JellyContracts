pragma solidity 0.8.6;

import "../Access/JellyMinterAccess.sol";
import "../OpenZeppelin/token/ERC20/ERC20.sol";
import "../OpenZeppelin/security/Pausable.sol";

/**
* @title Jelly Token:
*
*              ,,,,
*            g@@@@@@K
*           ]@@@@@@@@P
*            $@@@@@@@"                   ]@@@  ]@@@
*             "*NNM"                     ]@@@  ]@@@
*                                        ]@@@  ]@@@
*             ,g@@@g        ,,gg@gg,     ]@@@  ]@@@ ,ggg          ,ggg
*            @@@@@@@@p    g@@@BPMBB@@W   ]@@@  ]@@@  $@@@        ,@@@P
*           ]@@@@@@@@@   @@@P      ]@@@  ]@@@  ]@@@   $@@g      ,@@@P
*           ]@@@@@@@@@  $@@D,,,,,,,,]@@@ ]@@@  ]@@@   '@@@p     @@@C
*           ]@@@@@@@@@  @@@@NNNNNNNNNNNN ]@@@  ]@@@    "@@@p   @@@P
*           ]@@@@@@@@@  ]@@K             ]@@@  ]@@@     '@@@, @@@P
*            @@@@@@@@@   %@@@,    ,g@@@  ]@@@  ]@@@      ^@@@@@@C
*            "@@@@@@@@    "N@@@@@@@@N*   ]@@@  ]@@@       "*@@@P
*             "B@@@@@@        "**""       '''   '''        @@@P
*    ,gg@@g    "B@@@P                                     @@@P
*   @@@@@@@@p    B@@'                                    @@@P
*   @@@@@@@@P    ]@h                                    RNNP
*   'B@@@@@@     $P
*       "NE@@@p"'
*
*
*/

/**
* @author ProfWobble & Jiggle
* @dev
*  - Ability for holders to burn (destroy) their tokens
*  - Minter role that allows for token minting
*  - Token transfers paused on deployment (Jelly not set yet!).
*  - An operator role that allows for transfers of unset tokens.
*  - SetJelly() function that allows $JELLY to transfer when ready.
*
*/

contract Jelly is ERC20, Pausable, JellyMinterAccess {

    uint public cap;
    event CapUpdated(uint256 cap);
    event JellySet();

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE` to the account that deploys the contract
     *      and `OPERATOR_ROLE` to the vault to be able to move those tokens.
    */
    constructor(string memory _name, string memory _symbol, address _vault, uint256 _initialSupply, uint256 _cap) ERC20(_name,_symbol) {
        _setupRole(OPERATOR_ROLE, _vault);
        initAccessControls(_msgSender());
        require(_cap >= _initialSupply, "Cap exceeded");
        cap = _cap;
        _mint(_vault, _initialSupply);
        _pause();
    }

    /**
     * @dev Serves $JELLY when the time is just right.
     */
    function setJelly() external {
        require(
            hasAdminRole(_msgSender()),
            "JELLY.setJelly: Sender must be admin"
        );
        _unpause();
        emit JellySet();
    }

    /**
     * @dev Sets the hard cap on token supply.
     */
    function setCap(uint _cap) external  {
        require(
            hasAdminRole(_msgSender()),
            "JELLY.setCap: Sender must be admin"
        );
        require( _cap >= totalSupply(), "JELLY: Cap less than totalSupply");
        cap = _cap;
        emit CapUpdated(cap);
    }

    /**
     * @dev Checks if Jelly is ready yet.
     */
    function canTransfer(
        address _from
    ) external view returns (bool _status) {
        return (!paused() || hasOperatorRole(_msgSender()));
    }

    /**
     * @dev Returns the amount a user is permitted to mint.
     */
    function availableToMint() external view returns (uint256 tokens) {
        if (hasMinterRole(_msgSender())) {
            if (cap > 0) {
                tokens = cap - totalSupply();
            }
        }
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     */
    function mint(address to, uint256 amount) public {
        require(to != address(0), "JELLY: no mint to zero address");
        require(hasMinterRole(_msgSender()), "JELLY: must have minter role to mint");
        require(totalSupply() + amount <= cap, "Cap exceeded");
        _mint(to, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     *      allowance.
     */
    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "JELLY: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    /**
     * @dev Requires hasOperatorRole for token transfers before Jelly has been set.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (paused()) {
            require(hasOperatorRole(_msgSender()), "JELLY: tokens cannot be transferred until setJelly has been executed");
        }
    }


}
