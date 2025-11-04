# Akemona Contracts

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
pnpm test
```

You can also selectively run the Solidity or `node:test` tests:

```shell
pnpm hardhat test solidity
pnpm hardhat test nodejs
```

### Make a deployment to Sepolia

To run the deployment to a local chain:

```shell
pnpm hardhat ignition deploy ignition/modules/Counter.ts
```

To run the deployment to Sepolia, you need an account with funds to send the transaction. The provided Hardhat configuration includes a Configuration Variable called `SEPOLIA_PRIVATE_KEY`, which you can use to set the private key of the account you want to use.

You can set the `SEPOLIA_PRIVATE_KEY` variable using the `hardhat-keystore` plugin or by setting it as an environment variable.

To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
pnpm hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

```shell
pnpm hardhat ignition deploy --network sepolia ignition/modules/Counter.ts
```
