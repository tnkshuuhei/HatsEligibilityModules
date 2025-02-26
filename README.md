# HatsEligibilityModules

HatsEligibilityModules is a repo containing a number of separate eligility modules for [Hats Protocol](https://github.com/hats-protocol/hats-protocol). The modules are summarized below:

- HypercertsEligibility: checks if addresses holds at least one minimum balance of units of fractions

All contracts are based on the Hats Protocol's repo: [hats-module](https://github.com/Hats-Protocol/hats-module)

**Note**: The contracts in this repo have not been audited - use at your own risk.

## Deployments

[Implementation of HypercertsEligibilityModule v0.2.1 on sepolia](https://sepolia.etherscan.io/address/0x61ad280d6df95effd7fba439b547252f8e35b8c9)

## Development

This repo uses Foundry for development and testing. To get started:

1. Fork the project
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. To compile the contracts, run `forge build`
4. To test, run `pnpm test`. The tests require a private key and a valid mainnet rpc API KEY. A .env.example file is
   provided.
