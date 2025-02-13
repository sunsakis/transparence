# Transparence

A transparent payment system using USDC across multiple EVM chains.

## Deployed Contracts

- Sepolia: [contract address]
- Base: [contract address]
- Arbitrum: [contract address]

## Development

This project uses [Foundry](https://github.com/foundry-rs/foundry) for development and testing.

### Setup

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install dependencies:
```bash
forge install
```

3. Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

### Testing

```bash
forge test
forge test --gas-report # with gas reporting
forge test -vvv # with detailed traces
```

### Deployment

Make sure your `.env` file is configured with the correct RPC URLs and private key.

```bash
# Deploy to Sepolia
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify

# Deploy to Base
forge script script/Deploy.s.sol --rpc-url base --broadcast --verify

# Deploy to Arbitrum
forge script script/Deploy.s.sol --rpc-url arbitrum --broadcast --verify
```

## Usage

The contract accepts USDC payments and stores optional metadata for each transaction:

```solidity
function makePayment(
    address _to,
    uint256 _amount,
    string memory _category,
    string memory _description
) external
```

Remember that USDC uses 6 decimal places, so to send 1 USDC, use 1000000 as the amount.

## Security

This project is built with OpenZeppelin contracts and includes:
- ReentrancyGuard for protection against reentrancy attacks
- Safe ERC20 operations
- Input validation

## License

MIT