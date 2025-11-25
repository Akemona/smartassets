const constructorArgs = [
  "BIZPERKTEST",
  "BIZPERKTEST",
  "10000000000000",
  "100",
  "0x6b9a53d301b62441c30f56b887f1f7b8c191ac0a",
  "0xd97149b9ce08788d0903651eb5b80c62b5994d69",
] as const;

export default constructorArgs;

// command
// pnpm hardhat verify --network sepolia --constructor-args-path ./verify-contract/perk-constructor-args.ts 0x1234567890...
