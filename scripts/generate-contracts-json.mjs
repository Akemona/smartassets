/**
 * Emit a committed contracts.json ({ "<ContractName>": { abi, bytecode } }) from the compiled Hardhat
 * artifacts. Downstream repos (akemona-server's @akemona/blockchain-core, which is the single source of
 * truth that the frontend then syncs from) read this committed bundle straight from GitHub — no Hardhat
 * build needed on their side. This mirrors the committed contracts.json in Akemona/contracts_v1.
 *
 * Regenerate whenever a contract changes:
 *   pnpm hardhat compile && node scripts/generate-contracts-json.mjs
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const ROOT = resolve(import.meta.dirname, "..");

// Contracts exported downstream (skip test-only contracts like Counter).
const CONTRACTS = ["AkemonaERC20Perk", "AkemonaMerkleDistributor"];

const out = {};
for (const name of CONTRACTS) {
  const path = resolve(ROOT, `artifacts/contracts/${name}/${name}.sol/${name}.json`);
  const artifact = JSON.parse(readFileSync(path, "utf8"));
  if (!Array.isArray(artifact.abi) || typeof artifact.bytecode !== "string" || artifact.bytecode.length <= 2) {
    throw new Error(`bad/empty artifact for ${name} — run 'hardhat compile' first (${path})`);
  }
  out[name] = { abi: artifact.abi, bytecode: artifact.bytecode };
}

writeFileSync(resolve(ROOT, "contracts.json"), `${JSON.stringify(out, null, 2)}\n`);
console.log(`wrote contracts.json (${CONTRACTS.length} contracts: ${CONTRACTS.join(", ")})`);
