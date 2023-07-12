// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {HatsModule, HatsModuleFactory, IHats, Deploy} from "../script/HatsModuleFactory.s.sol";
import {DecentralistEligibility} from "src/DecentralistEligibilityModule.sol";

// NOTE: this test script does not deploy Decentralist or UMA contracts, soit must be run on Goerli
contract DecentralistEligibilityTest is Deploy, Test {
    string public FACTORY_VERSION = "test factory";
    string public MODULE_VERSION = "module test version";
    address public LIST_ADDRESS = 0x7034362c495552470aD86a3A86A57c16Fe5C82B3; // Mainnet address
    address public eligible = 0xdB19c47E87Ed3Ff37425a99B9Dee1f4920F755b9; // Mainnet address
    address public ineligible = makeAddr("ineligible");

    DecentralistEligibility public instance;
    DecentralistEligibility public implementation;

    uint256 public fork;
    uint256 public BLOCK_NUMBER = 16_947_805;

    function setUp() external {
        //set up fork to read from existing decentralist list
        fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

        //deploy HatsModuleFactory
        Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
        Deploy.run();

        //deploy DecentralistHatsEligbilityModule implementation
        implementation = new DecentralistEligibility(MODULE_VERSION);

        //create DecentralistHatsEligbilityModule instance
        instance = DecentralistEligibility(
            factory.createHatsModule(
                address(implementation),
                0,
                abi.encodePacked(LIST_ADDRESS),
                ""
            )
        );
    }
}

contract Constructor is DecentralistEligibilityTest {
    function test_version__() public {
        // version_ is the value in the implementation contract
        assertEq(
            implementation.version_(),
            MODULE_VERSION,
            "implementation version"
        );
    }

    function test_version_reverts() public {
        vm.expectRevert();
        implementation.version();
    }
}

contract SetUp is DecentralistEligibilityTest {
    function test_Immutables() external {
        assertEq(
            instance.LIST_ADDRESS(),
            LIST_ADDRESS,
            "incorrect token address"
        );
    }
}

contract GetWearerStatus is DecentralistEligibilityTest {
    function _eligibilityCheck(address _wearer, bool expect) internal {
        (bool eligible, bool standing) = instance.getWearerStatus(_wearer, 0);
        assertEq(eligible, expect);
        assertEq(standing, true);
    }

    function test_getWearerStatus_true_true() public {
        _eligibilityCheck(eligible, true);
    }

    function test_getWearerStatus_false_true() public {
        _eligibilityCheck(ineligible, false);
    }
}
