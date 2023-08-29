// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { MultiERC1155Eligibility } from "../src/MultiERC1155EligibilityModule.sol";

contract Deploy is Script {
  MultiERC1155Eligibility implementation;
  bytes32 internal constant SALT = bytes32(abi.encode(0x4a75)); // ~ H(4) A(a) T(7) S(5)

  // variables with defaul values
  string public version = "0.2.0"; // increment with each deploy
  bool verbose = true;

  /// @notice Overrides default values
  function prepare(string memory _version, bool _verbose) public {
    version = _version;
    verbose = _verbose;
  }

  function run() public {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.rememberKey(privKey);

    vm.startBroadcast(deployer);
    // deploy the implementation
    implementation = new MultiERC1155Eligibility{ salt: SALT }(version);
    vm.stopBroadcast();

    if (verbose) {
      console2.log("implementation", address(implementation));
    }
  }
  // forge script script/MultiERC1155EligibilityModule.s.sol:Deploy -f goerli --broadcast --verify
}
