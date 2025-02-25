// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {IERC1155} from "@openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {HatsModule, HatsModuleFactory, IHats, Deploy} from "../script/HatsModuleFactory.s.sol";
import {HypercertsEligibility} from "src/HypercertsEligibilityModule.sol";
import {IHypercertToken} from "src/interfaces/IHypercertToken.sol";

// forge test --fork-url https://sepolia.drpc.org --match-path test/HypercertsEligibility.t.sol

contract HypercertsEligibilityTest is Deploy, Test {
    string public FACTORY_VERSION = "factory test version";
    string public MODULE_VERSION = "module test version";
    uint256 public constant TOKEN_ID =
        296385941588137401676599283073070112178177;
    uint256[] public TOKEN_IDS = [
        296385941588137401676599283073070112178177,
        296385941588137401676599283073070112178178
    ];
    uint256[] public MIN_BALANCES_OF_UNITS = [50_000_000, 50_000_000];
    address public eligible1 = 0xc3593524E2744E547f013E17E6b0776Bc27Fc614;
    address public eligible2 = makeAddr("eligible2");
    address public ineligible1 = makeAddr("ineligible1");

    HypercertsEligibility public instance;
    IHypercertToken public hypercerts;
    HypercertsEligibility public implementation;

    function setUp() external {
        //deploy HatsModuleFactory
        Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
        Deploy.run();

        configureChain();

        // make sure eligible1 has 100_000_000 units
        assertEq(
            hypercerts.unitsOf(
                eligible1,
                296385941588137401676599283073070112178177
            ),
            100000000
        );

        vm.startPrank(eligible1);
        // approve hypercerts befor spliting the tokens
        IERC1155(address(hypercerts)).setApprovalForAll(
            address(hypercerts),
            true
        );

        // splits the tokens
        // ...77 100_000_000 -> 50_000_000
        // ...78 0 -> 50_000_000
        hypercerts.splitFraction(eligible2, TOKEN_ID, MIN_BALANCES_OF_UNITS);

        // make sure the split worked
        assertEq(
            hypercerts.unitsOf(
                eligible1,
                296385941588137401676599283073070112178177
            ),
            50_000_000
        );
        assertEq(
            hypercerts.unitsOf(
                eligible2,
                296385941588137401676599283073070112178178
            ),
            50_000_000
        );

        //deploy HypercertsEligibility implementation
        implementation = new HypercertsEligibility(MODULE_VERSION);

        bytes memory otherImmutableArgs = abi.encodePacked(
            address(hypercerts),
            TOKEN_IDS.length,
            TOKEN_IDS,
            MIN_BALANCES_OF_UNITS
        );

        //create HypercertsEligibility instance
        instance = HypercertsEligibility(
            factory.createHatsModule(
                address(implementation),
                0,
                otherImmutableArgs,
                ""
            )
        );
    }

    function configureChain() public {
        if (block.chainid == 11_155_111) {
            // on sepolia fork test
            hypercerts = IHypercertToken(
                0xa16DFb32Eb140a6f3F2AC68f41dAd8c7e83C4941
            );
        } else {
            revert("unsupported chain");
        }
    }
}

contract Constructor is HypercertsEligibilityTest {
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

contract SetUp is HypercertsEligibilityTest {
    function test_Immutables() external {
        assertEq(
            instance.TOKEN_ADDRESS(),
            address(hypercerts),
            "incorrect token address"
        );
        assertEq(
            instance.ARRAY_LENGTH(),
            TOKEN_IDS.length,
            "incorrect array lengths"
        );
        assertEq(instance.TOKEN_IDS(), TOKEN_IDS, "incorrect token id");
        assertEq(
            instance.MIN_BALANCES_OF_UNITS(),
            MIN_BALANCES_OF_UNITS,
            "incorrect MIN_BALANCES_OF_UNITS"
        );
    }
}

contract GetWearerStatus is HypercertsEligibilityTest {
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
