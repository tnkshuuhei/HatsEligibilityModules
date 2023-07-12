// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {ERC1155} from "@openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {HatsModule, HatsModuleFactory, IHats, Deploy} from "../script/HatsModuleFactory.s.sol";
import {ERC1155Eligibility} from "src/ERC1155EligibilityModule.sol";

contract MintableERC1155 is ERC1155 {
    constructor() ERC1155("") {}

    function mint(address to, uint256 tokenId, uint256 amount) public {
        _mint(to, tokenId, amount, "");
    }
}

contract ERC1155EligibilityTest is Deploy, Test {
    string public FACTORY_VERSION = "factory test version";
    string public MODULE_VERSION = "module test version";
    uint256[] public TOKEN_IDS = [1, 2];
    uint256[] public MIN_BALANCES = [1, 1000];
    address public eligible1 = makeAddr("eligible1");
    address public eligible2 = makeAddr("eligible2");
    address public ineligible1 = makeAddr("ineligible1");

    ERC1155Eligibility public instance;
    MintableERC1155 public mintableERC1155;
    ERC1155Eligibility public implementation;

    function setUp() external {
        //deploy HatsModuleFactory
        Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
        Deploy.run();

        //deploy ERC1155 contract & mint to test addresses
        mintableERC1155 = new MintableERC1155();
        mintableERC1155.mint(ineligible1, TOKEN_IDS[0], MIN_BALANCES[0] - 1);
        mintableERC1155.mint(eligible1, TOKEN_IDS[0], MIN_BALANCES[0]);
        mintableERC1155.mint(eligible2, TOKEN_IDS[1], MIN_BALANCES[1]);

        //deploy ERC1155HatsEligbility implementation
        implementation = new ERC1155Eligibility(MODULE_VERSION);

        bytes memory otherImmutableArgs = abi.encodePacked(
            address(mintableERC1155),
            TOKEN_IDS.length,
            TOKEN_IDS,
            MIN_BALANCES
        );

        //create ERC1155HatsEligbility instance
        instance = ERC1155Eligibility(
            factory.createHatsModule(
                address(implementation),
                0,
                otherImmutableArgs,
                ""
            )
        );
    }
}

contract Constructor is ERC1155EligibilityTest {
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

contract SetUp is ERC1155EligibilityTest {
    function test_Immutables() external {
        assertEq(
            instance.TOKEN_ADDRESS(),
            address(mintableERC1155),
            "incorrect token address"
        );
        assertEq(instance.ARRAY_LENGTH(), TOKEN_IDS.length, "incorrect array lengths");
        assertEq(instance.TOKEN_IDS(), TOKEN_IDS, "incorrect token id");
        assertEq(instance.MIN_BALANCES(), MIN_BALANCES, "incorrect min balance");
    }
}

contract GetWearerStatus is ERC1155EligibilityTest {
    function _eligibilityCheck(address _wearer, bool expect) internal {
        (bool eligible, bool standing) = instance.getWearerStatus(_wearer, 0);
        assertEq(eligible, expect);
        assertEq(standing, true);
    }

    function test_getWearerStatus_true_true() public {
        _eligibilityCheck(eligible1, true);
        _eligibilityCheck(eligible2, true);
    }

    function test_getWearerStatus_false_true() public {
        _eligibilityCheck(ineligible1, false);
    }
}
