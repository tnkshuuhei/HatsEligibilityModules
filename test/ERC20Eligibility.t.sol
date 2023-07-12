// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {HatsModule, HatsModuleFactory, IHats, Deploy} from "../script/HatsModuleFactory.s.sol";
import {ERC20Eligibility} from "src/ERC20EligibilityModule.sol";

contract MintableERC20 is ERC20 {
    constructor() ERC20("Test Token", "TT") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ERC20EligibilityTest is Deploy, Test {
    string public FACTORY_VERSION = "test factory";
    string public MODULE_VERSION = "module test version";
    uint256 public MIN_BALANCE = 1;

    address public eligible1 = makeAddr("eligible1");
    address public eligible2 = makeAddr("eligible2");
    address public ineligible1 = makeAddr("ineligible1");

    ERC20Eligibility public instance;
    MintableERC20 public mintableERC20;
    ERC20Eligibility public implementation;

    function setUp() external {
        //deploy HatsModuleFactory
        Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
        Deploy.run();

        //deploy ERC20 contract & mint to test addresses
        mintableERC20 = new MintableERC20();
        mintableERC20.mint(eligible1, 1);
        mintableERC20.mint(eligible2, 2);

        //deploy ERC20HatsEligbilityModule implementation
        implementation = new ERC20Eligibility(MODULE_VERSION);

        bytes memory otherImmutableArgs = abi.encodePacked(
            address(mintableERC20),
            MIN_BALANCE
        );

        //create ERC20HatsEligbilityModule instance
        instance = ERC20Eligibility(
            factory.createHatsModule(
                address(implementation),
                0,
                otherImmutableArgs,
                ""
            )
        );
    }
}

contract Constructor is ERC20EligibilityTest {
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

contract SetUp is ERC20EligibilityTest {
    function test_Immutables() external {
        assertEq(
            instance.TOKEN_ADDRESS(),
            address(mintableERC20),
            "incorrect token address"
        );
        assertEq(instance.MIN_BALANCE(), MIN_BALANCE, "incorrect min balance");
    }
}

contract GetWearerStatus is ERC20EligibilityTest {
    function _eligibilityCheck(address _wearer, bool expect) internal {
        (bool eligible, bool standing) = instance.getWearerStatus(_wearer, 0);
        assertEq(eligible, expect);
        assertEq(standing, true);
    }

    function test_getWearerStatus_true_true() public {
        _eligibilityCheck(eligible1, true);
    }

    function test_getWearerStatus_false_true() public {
        _eligibilityCheck(ineligible1, false);
    }
}
