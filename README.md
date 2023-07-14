# HatsEligibilityModules

HatsEligibilityModules is a repo containing a number of separate eligility modules for [Hats Protocol](https://github.com/hats-protocol/hats-protocol). The modules are summarized below:
- AddressEligibility: check if addresses are on a whitelist that admins can edit
- DecentralistEligibility: checks if an address is on a [Decentralist](https://www.decentra-list.xyz/) list
- ERC20Eligibility: checks if addresses meet a minimum balance of an ERC20 token
- ERC721Eligibility: checks if addresses meet a minimum balance of an ERC721 token
- ERC1155Eligibility: checks if addresses holds at least one minimum balance of a set of ERC1155 token Ids

All contracts are based on the Hats Protocol's repo: [hats-module](https://github.com/Hats-Protocol/hats-module)

**Note**: The contracts in this repo have not been audited - use at your own risk.

## Deployments

For information on Hats Protocol versions and deployments, see (Releases)[https://github.com/pumpedlunch/HatsEligibilityModules/releases].

## Development

This repo uses Foundry for development and testing. To get started:

1. Fork the project
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. To compile the contracts, run `forge build`
4. To test, run `forge test`. The tests require a private key and a valid mainnet rpc API KEY. A .env.example file is
   provided.
