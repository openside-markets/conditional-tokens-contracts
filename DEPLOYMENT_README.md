# Deployment and Contract Verification Guide

This guide covers how to deploy contracts to new networks, update the `networks.json` file, and manually verify contracts on block explorers.

## Table of Contents

1. [Deploying to New Networks](#deploying-to-new-networks)
2. [Updating networks.json](#updating-networksjson)
3. [Manual Contract Verification](#manual-contract-verification)
4. [Troubleshooting](#troubleshooting)

## Deploying to New Networks

### Prerequisites

- Node.js and npm/yarn installed
- Truffle installed (`npm install -g truffle`)
- Private key or mnemonic for deployment
- Sufficient ETH for gas fees

### Step 1: Configure Network

Add your new network to `truffle-local.js`:

```javascript
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    // Existing networks...
    
    your_new_network: {
      provider: () => {
        const provider = new HDWalletProvider(
          process.env.PRIVATE_KEY || "your-private-key-here",
          "https://your-rpc-url.com"
        );
        return provider;
      },
      network_id: YOUR_CHAIN_ID,
      gas: 10000000,
      gasPrice: 1000000000, // 1 gwei
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  }
};
```

### Step 2: Set Environment Variables

Create or update `.env` file:

```bash
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

### Step 3: Deploy Contracts

```bash
# Compile contracts
npm run compile

# Deploy to your network
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef truffle migrate --network your_new_network
```

### Step 4: Verify Deployment

```bash
# Check deployment status
npm run networks
```

## Updating networks.json

The `networks.json` file contains deployment information for all networks. Here's how to update it:

### Automatic Update (Recommended)

After successful deployment, run:

```bash
npm run injectnetinfo
```

This command automatically updates `networks.json` with the latest deployment information.

### Manual Update

If automatic update fails, you can manually add entries to `networks.json`:

#### 1. Find Contract Information

Check the build artifacts for deployment details:

```bash
# Check ConditionalTokens deployment
grep -A 5 -B 5 "YOUR_CHAIN_ID" build/contracts/ConditionalTokens.json

# Check Migrations deployment  
grep -A 5 -B 5 "YOUR_CHAIN_ID" build/contracts/Migrations.json
```

#### 2. Add to networks.json

Add entries to both `ConditionalTokens` and `Migrations` sections:

```json
{
  "ConditionalTokens": {
    "1": { /* existing mainnet */ },
    "4": { /* existing rinkeby */ },
    "100": { /* existing xdai */ },
    "YOUR_CHAIN_ID": {
      "events": {
        "0xab3760c3bd2bb38b5bcf54dc79802ed67338b4cf29f3054ded67ed24661e4177": {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "name": "conditionId",
              "type": "bytes32"
            },
            {
              "indexed": true,
              "name": "oracle",
              "type": "address"
            },
            {
              "indexed": true,
              "name": "questionId",
              "type": "bytes32"
            },
            {
              "indexed": false,
              "name": "outcomeSlotCount",
              "type": "uint256"
            }
          ],
          "name": "ConditionPreparation",
          "type": "event",
          "signature": "0xab3760c3bd2bb38b5bcf54dc79802ed67338b4cf29f3054ded67ed24661e4177"
        },
        // ... add all other event signatures from existing networks
      },
      "links": {},
      "address": "0xYOUR_CONTRACT_ADDRESS",
      "transactionHash": "0xYOUR_DEPLOYMENT_TX_HASH"
    }
  },
  "Migrations": {
    "1": { /* existing mainnet */ },
    "4": { /* existing rinkeby */ },
    "100": { /* existing xdai */ },
    "YOUR_CHAIN_ID": {
      "events": {},
      "links": {},
      "address": "0xYOUR_MIGRATIONS_ADDRESS",
      "transactionHash": "0xYOUR_MIGRATIONS_TX_HASH"
    }
  }
}
```

#### 3. Copy Event Signatures

Copy all event signatures from an existing network (e.g., mainnet) to ensure consistency:

```bash
# Extract event signatures from mainnet
grep -A 20 '"1":' networks.json
```

## Manual Contract Verification

### Prerequisites

- Contract source code
- Compiler version used
- Contract address
- Block explorer API key (optional)

### Step 1: Flatten Contract

Flatten the contract to include all dependencies:

```bash
# Install truffle-flattener if not already installed
npm install -g truffle-flattener

# Flatten the ConditionalTokens contract
npx truffle-flattener contracts/ConditionalTokens.sol > ConditionalTokens_flattened.sol
```

### Step 2: Get Compiler Information

Check the exact compiler version used:

```bash
grep -A 5 -B 5 "compiler" build/contracts/ConditionalTokens.json
```

Example output:
```json
"compiler": {
  "name": "solc",
  "version": "0.5.10+commit.5a6ea5b1.Emscripten.clang"
}
```

### Step 3: Verify on Block Explorer

#### Base Sepolia (BaseScan)

1. **Go to verification page**: https://sepolia.basescan.org/verifyContract

2. **Fill in details**:
   - **Contract Address**: `0xb29d3bb7c57bc2e8f72a516cd16e998ac0a05b1d`
   - **Contract Name**: `ConditionalTokens`
   - **Compiler Type**: `Solidity (Single file)`
   - **Compiler Version**: `v0.5.10+commit.5a6ea5b1.Emscripten.clang`
   - **Optimization**: `Yes` (enabled)
   - **Runs**: `200` (default)
   - **License**: `LGPL-3.0`

3. **Paste source code**: Copy entire content of `ConditionalTokens_flattened.sol`

4. **Submit**: Complete CAPTCHA and click "Verify and Publish"

#### Base Mainnet (BaseScan)

1. **Go to verification page**: https://basescan.org/verifyContract

2. **Use same details** as Base Sepolia

3. **Submit verification**

#### Other Networks

For other networks, find their respective block explorers:

- **Ethereum Mainnet**: https://etherscan.io/verifyContract
- **Polygon**: https://polygonscan.com/verifyContract
- **Arbitrum**: https://arbiscan.io/verifyContract
- **Optimism**: https://optimistic.etherscan.io/verifyContract

### Step 4: API Verification (Optional)

For automated verification, use the block explorer API:

```bash
# Base Sepolia API example
curl -X POST https://api-sepolia.basescan.org/api \
  -F 'apikey=YOUR_API_KEY' \
  -F 'module=contract' \
  -F 'action=verifysourcecode' \
  -F 'address=0xb29d3bb7c57bc2e8f72a516cd16e998ac0a05b1d' \
  -F 'sourceCode=@ConditionalTokens_flattened.sol' \
  -F 'contractname=ConditionalTokens' \
  -F 'compilerversion=v0.5.10+commit.5a6ea5b1.Emscripten.clang' \
  -F 'license=LGPL-3.0'
```

## Troubleshooting

### Deployment Issues

#### "Expected parameter 'from' not passed"
- **Cause**: HDWalletProvider not properly configured
- **Solution**: Ensure private key is correctly set in environment

#### "ran out of gas"
- **Cause**: Gas limit too low
- **Solution**: Increase gas limit in network configuration

#### "Unknown address - unable to sign transaction"
- **Cause**: Private key doesn't match the 'from' address
- **Solution**: Remove explicit 'from' address, let HDWalletProvider handle it

### Verification Issues

#### "Contract source code verification failed"
- **Cause**: Compiler version mismatch
- **Solution**: Use exact compiler version from build artifacts

#### "Source code too large"
- **Cause**: Contract has too many dependencies
- **Solution**: Use "Solidity (Multi-file)" instead of "Single file"

#### "Constructor arguments required"
- **Cause**: Contract has constructor parameters
- **Solution**: Provide constructor arguments during verification

### networks.json Issues

#### "networks.json not updated after deployment"
- **Cause**: injectnetinfo command failed
- **Solution**: Run `npm run injectnetinfo` manually

#### "Missing event signatures"
- **Cause**: Incomplete event data
- **Solution**: Copy event signatures from existing networks

## Best Practices

1. **Always test on testnet first** before mainnet deployment
2. **Keep private keys secure** and never commit them to version control
3. **Verify contracts immediately** after deployment
4. **Update networks.json** after each successful deployment
5. **Use environment variables** for sensitive configuration
6. **Test contract functionality** after deployment and verification

## Network-Specific Notes

### Base Sepolia
- **Chain ID**: 84532
- **RPC URL**: https://sepolia.base.org
- **Block Explorer**: https://sepolia.basescan.org
- **Testnet ETH**: Available from Base faucets

### Base Mainnet
- **Chain ID**: 8453
- **RPC URL**: https://mainnet.base.org
- **Block Explorer**: https://basescan.org
- **Gas Fees**: Lower than Ethereum mainnet

## Useful Commands

```bash
# Compile contracts
npm run compile

# Deploy to specific network
truffle migrate --network network_name

# Check deployment status
npm run networks

# Update networks.json
npm run injectnetinfo

# Flatten contract for verification
npx truffle-flattener contracts/ConditionalTokens.sol > flattened.sol

# Check compiler version
grep "compiler" build/contracts/ConditionalTokens.json
```

## Support

For issues with this deployment process:
1. Check the troubleshooting section above
2. Review Truffle documentation: https://trufflesuite.com/docs/
3. Check Base documentation: https://docs.base.org/
4. Verify contract on block explorer for debugging
