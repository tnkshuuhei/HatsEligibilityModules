// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
//asd

import {Test, console2} from "forge-std/Test.sol";
import {HatsModule, HatsModuleFactory, IHats, Deploy} from "../script/HatsModuleFactory.s.sol";
import {AddressEligibility} from "src/AddressEligibilityModule.sol";

contract AddressEligibilityTest is Deploy, Test {
    error AddressEligibility_NotHatAdmin();

    AddressEligibility public implementation;
    AddressEligibility public instance;

    uint256 public tophat;
    uint256 public hat;

    address public dao = makeAddr("dao");
    address public notAdmin = makeAddr("notAdmin");

    address[] public initEligible = [
        makeAddr("initEligible0"),
        makeAddr("initEligible1")
    ];
    address public addEligible1 = makeAddr("addEligible1");
    address public addEligible2 = makeAddr("addEligible2");
    address public ineligible1 = makeAddr("ineligible1");

    bytes public otherImmutableArgs = "";
    bytes public initData = abi.encode(initEligible);

    uint256 public fork;
    uint256 public BLOCK_NUMBER = 16_947_805; // the block number where v1.hatsprotocol.eth was deployed;
    string public FACTORY_VERSION = "factory test version";
    string public MODULE_VERSION = "module test version";

    address public defaultModule = address(0x4a75);

    error ERC721Eligibility_NotHatAdmin();

    event AddressEligibility_Deployed(address[] addEligibleresses);
    event AddressEligibility_AddressesAdded(address[] addresses);
    event AddressEligibility_AddressesRemoved(address[] addresses);

    function deployFactory() public {
        //deploy HatsModuleFactory
        Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
        Deploy.run();
    }

    function createHats() public {
        vm.startPrank(dao);
        tophat = hats.mintTopHat(dao, "tophat", "");
        hat = hats.createHat(
            tophat,
            "requires admin to whitelist",
            5,
            defaultModule,
            defaultModule,
            true,
            ""
        );
        vm.stopPrank();
    }

    function deployInstance() public {
        //deploy AddressEligibility implementation
        implementation = new AddressEligibility(MODULE_VERSION);

        //create AddressEligibility instance with initEligibles made eligible
        otherImmutableArgs = "";
        initData = abi.encode(initEligible);

        instance = AddressEligibility(
            factory.createHatsModule(
                address(implementation),
                hat,
                otherImmutableArgs,
                initData
            )
        );

        //set instance as eligibility module for hat
        vm.startPrank(dao);
        hats.changeHatEligibility(hat, address(instance));
        vm.stopPrank();
    }

    function setUp() external {
        fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

        deployFactory();
        createHats();
        deployInstance();
    }

    function _eligibilityCheck(address _wearer, bool expect) internal {
        (bool eligible, bool standing) = instance.getWearerStatus(_wearer, hat);
        assertEq(eligible, expect);
        assertEq(standing, true);
    }
}

contract Constructor is AddressEligibilityTest {
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

contract SetUp is AddressEligibilityTest {
    function test_Immutables() public {
        assertEq(address(instance.HATS()), address(hats), "hats");
        assertEq(
            address(instance.IMPLEMENTATION()),
            address(implementation),
            "implementation"
        );
        assertEq(instance.hatId(), hat, "hatId");
    }

    function test_SetUpEligibilities() external {
        _eligibilityCheck(initEligible[0], true);
        _eligibilityCheck(initEligible[1], true);
        _eligibilityCheck(ineligible1, false);
    }
}

contract AdminFunctions is AddressEligibilityTest {
    function test_AddEligibleAddresses() external {
        address[] memory addEligible = new address[](2);
        addEligible[0] = addEligible1;
        addEligible[1] = addEligible2;
        vm.prank(dao);
        instance.addEligibleAddresses(addEligible);

        _eligibilityCheck(addEligible1, true);
        _eligibilityCheck(addEligible2, true);
    }

    function test_RemoveEligibleAddresses() external {
        address[] memory removeEligible = new address[](2);
        removeEligible[0] = initEligible[0];
        removeEligible[1] = initEligible[1];
        vm.prank(dao);
        instance.removeEligibleAddresses(removeEligible);

        _eligibilityCheck(removeEligible[0], false);
        _eligibilityCheck(removeEligible[1], false);
    }

    function test_NonHatAdmin_Reverts() external {
        address[] memory addEligible = new address[](1);
        addEligible[0] = addEligible1;
        // expect a revert
        vm.expectRevert(AddressEligibility_NotHatAdmin.selector);
        vm.prank(notAdmin);
        instance.addEligibleAddresses(addEligible);
    }
}
