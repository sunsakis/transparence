// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TransparentPayments.sol";
import "../test/mocks/MockERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address usdcAddress;
        
        if (block.chainid == 11155111) {
            // Sepolia USDC
            usdcAddress = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // Bridge USDC
        } else if (block.chainid == 8453) {
            // Base Mainnet USDC
            usdcAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        } else if (block.chainid == 42161) {
            // Arbitrum One USDC
            usdcAddress = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
        } else {
            // For testing, deploy a mock USDC
            MockERC20 mockUSDC = new MockERC20("USD Coin", "USDC", 6);
            usdcAddress = address(mockUSDC);
        }

        TransparentPayments payments = new TransparentPayments(usdcAddress);
        console.log("TransparentPayments deployed to:", address(payments));
        
        vm.stopBroadcast();
    }
}