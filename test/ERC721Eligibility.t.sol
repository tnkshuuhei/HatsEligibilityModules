// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721 } from "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { HatsModule, HatsModuleFactory, IHats, Deploy } from "../script/HatsModuleFactory.s.sol";
import { ERC721Eligibility } from "src/ERC721EligibilityModule.sol";

contract MintableERC721 is ERC721 {
  constructor() ERC721("Test NFT", "TNFT") { }

  function mint(address to, uint256 tokenId) public {
    _mint(to, tokenId);
  }
}

contract ERC721EligibilityTest is Deploy, Test {
  string public FACTORY_VERSION = "test factory";
  string public MODULE_VERSION = "module test version";
  uint256 public MIN_BALANCE = 1;

  address public eligible1 = makeAddr("eligible1");
  address public eligible2 = makeAddr("eligible2");
  address public ineligible1 = makeAddr("ineligible1");

  ERC721Eligibility public instance;
  MintableERC721 public mintableERC721;
  ERC721Eligibility public implementation;

  function setUp() external {
    //deploy HatsModuleFactory
    Deploy.prepare(FACTORY_VERSION, false); // set to true to log deployment addresses
    Deploy.run();

    //deploy ERC721 contract & mint to test addresses
    mintableERC721 = new MintableERC721();
    mintableERC721.mint(eligible1, 1);
    mintableERC721.mint(eligible2, 2);

    //deploy ERC721HatsEligbilityModule implementation
    implementation = new ERC721Eligibility(MODULE_VERSION);

    bytes memory otherImmutableArgs = abi.encodePacked(address(mintableERC721), MIN_BALANCE);

    //create ERC721HatsEligbilityModule instance
    instance = ERC721Eligibility(factory.createHatsModule(address(implementation), 0, otherImmutableArgs, ""));
  }
}

contract Constructor is ERC721EligibilityTest {
  function test_version__() public {
    // version_ is the value in the implementation contract
    assertEq(implementation.version_(), MODULE_VERSION, "implementation version");
  }

  function test_version_reverts() public {
    vm.expectRevert();
    implementation.version();
  }
}

contract SetUp is ERC721EligibilityTest {
  function test_Immutables() external {
    assertEq(instance.ERC721_TOKEN_ADDRESS(), address(mintableERC721), "incorrect token address");
    assertEq(instance.MIN_BALANCE(), MIN_BALANCE, "incorrect min balance");
  }
}

contract GetWearerStatus is ERC721EligibilityTest {
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
