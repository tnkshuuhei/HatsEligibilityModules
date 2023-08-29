// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import { console2 } from "forge-std/Test.sol"; // remove before deploy
import { HatsEligibilityModule, HatsModule } from "hats-module/HatsEligibilityModule.sol";
import { DecentralistInterface } from "decentralist/DecentralistInterface.sol";

/**
 * @title DecentralistEligibility
 * @author pumpedlunch
 * @notice A Hats Protocol eligibility module that checks if an address is on a Decentralist list
 */

contract DecentralistEligibility is HatsEligibilityModule {
  /*//////////////////////////////////////////////////////////////
                          PUBLIC CONSTANTS
    //////////////////////////////////////////////////////////////*/

  /**
   * See: https://github.com/Hats-Protocol/hats-module/blob/main/src/HatsModule.sol
   * --------------------------------------------------------------------+
   * CLONE IMMUTABLE "STORAGE"                                           |
   * --------------------------------------------------------------------|
   * Offset  | Constant        | Type    | Length  |                     |
   * --------------------------------------------------------------------|
   * 0       | IMPLEMENTATION  | address | 20      |                     |
   * 20      | HATS            | address | 20      |                     |
   * 40      | hatId           | uint256 | 32      |                     |
   * 72      | LIST_ADDRESS    | address | 20      |                     |
   * --------------------------------------------------------------------+
   */

  /// The address of the Decentralist contract used to check eligibility
  function LIST_ADDRESS() public pure returns (address) {
    return _getArgAddress(72);
  }

  /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
  constructor(string memory _version) HatsModule(_version) { }

  /*//////////////////////////////////////////////////////////////
                        HATS ELIGIBILITY FUNCTION
    //////////////////////////////////////////////////////////////*/
  ///
  function getWearerStatus(address _wearer, uint256 /*_hatId */ )
    public
    view
    override
    returns (bool eligible, bool standing)
  {
    eligible = DecentralistInterface(LIST_ADDRESS()).onList(_wearer);
    standing = true;
  }
}
