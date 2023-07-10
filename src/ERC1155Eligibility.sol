// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import { console2 } from "forge-std/Test.sol"; // remove before deploy
import {HatsEligibilityModule, HatsModule} from "hats-module/HatsEligibilityModule.sol";
import {IERC1155} from "@openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title ERC1155Eligibility
 * @author pumpedlunch
 * @notice A Hats Protocol eligibility module that checks if addresses holds at least one minimum balance of a set of ERC1155 token Ids
 */

contract ERC1155Eligibility is HatsEligibilityModule {
    /*//////////////////////////////////////////////////////////////
                          PUBLIC CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * See: https://github.com/Hats-Protocol/hats-module/blob/main/src/HatsModule.sol
     * -----------------------------------------------------------------+
     * CLONE IMMUTABLE "STORAGE"                                        |
     * -----------------------------------------------------------------|
     * Offset             | Constant        | Type    | Length          |
     * -----------------------------------------------------------------|
     * 0                  | IMPLEMENTATION  | address | 20              |
     * 20                 | HATS            | address | 20              |
     * 40                 | hatId           | uint256 | 32              |
     * 72                 | TOKEN_ADDRESS   | address | 20              |
     * 92                 | ARRAY_LENGTH    | uint256 | 32              |
     * 124                | TOKEN_IDS       | uint256 | ARRAY_LENGTH*32 |
     * 124+(ARRAY_LENGTH) | MIN_BALANCES    | uint256 | ARRAY_LENGTH*32 |
     * -----------------------------------------------------------------+
     */

    /// The address of the ERC1155 contract used to check eligibility
    function TOKEN_ADDRESS() public pure returns (address) {
        return _getArgAddress(72);
    }

    /// The address of the ERC1155 contract used to check eligibility
    function ARRAY_LENGTH() public pure returns (uint256) {
        return _getArgUint256(92);
    }

    /// The token IDs that allow eligibility. Wearer must satisfy only one token ID criteria for eligiblity
    function TOKEN_IDS() public pure returns (uint256[] memory) {
        return _getArgUint256Array(124, ARRAY_LENGTH());
    }

    /// The minimum balances required (for token ID in the corresponding index) for eligibility.
    /// Wearer must satisfy only one token ID criteria for eligiblity
    function MIN_BALANCES() public pure returns (uint256[] memory) {
        return _getArgUint256Array(124 + ARRAY_LENGTH() * 32, ARRAY_LENGTH());
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Deploy the ERC20Eligibility implementation contract and set its version
     * @dev This is only used to deploy the implementation contract, and should not be used to deploy clones
     */
    constructor(string memory _version) HatsModule(_version) {}

    /*//////////////////////////////////////////////////////////////
                        HATS ELIGIBILITY FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc HatsEligibilityModule
     */
    function getWearerStatus(
        address _wearer,
        uint256 /*_hatId */
    ) public view override returns (bool eligible, bool standing) {
        uint256 len = ARRAY_LENGTH();
        IERC1155 token = IERC1155(TOKEN_ADDRESS());
        uint256[] memory tokenIds = TOKEN_IDS();
        uint256[] memory minBalances = MIN_BALANCES();

        for (uint256 i = 0; i < len; i++) {
            if (token.balanceOf(_wearer, tokenIds[i]) >= minBalances[i]) {
                eligible = true;
                break;
            }
        }
        standing = true;
    }
}
