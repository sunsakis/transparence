// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TransparentPayments.sol";
import "./mocks/MockERC20.sol";

contract TransparentPaymentsTest is Test {
    TransparentPayments public payments;
    MockERC20 public usdc;
    address public user1;
    address public user2;

    function setUp() public {
        // Deploy mock USDC
        usdc = new MockERC20("USD Coin", "USDC", 6);
        
        // Deploy TransparentPayments
        payments = new TransparentPayments(address(usdc));
        
        // Setup test accounts
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Fund user1 with USDC
        usdc.mint(user1, 1000 * 10**6);
        
        // Set user1 as msg.sender
        vm.startPrank(user1);
        usdc.approve(address(payments), type(uint256).max);
        vm.stopPrank();
    }

    function testMakePayment() public {
        uint256 amount = 100 * 10**6; // 100 USDC
        
        vm.startPrank(user1);
        payments.makePayment(user2, amount, "Test", "Test Payment");
        vm.stopPrank();

        (
            address from,
            address to,
            uint256 paymentAmount,
            string memory category,
            string memory description,
            uint256 timestamp
        ) = payments.getPayment(0);

        assertEq(from, user1);
        assertEq(to, user2);
        assertEq(paymentAmount, amount);
        assertEq(category, "Test");
        assertEq(description, "Test Payment");
        assertEq(usdc.balanceOf(user2), amount);
    }

    function testFailInsufficientBalance() public {
        uint256 amount = 2000 * 10**6; // More than minted
        
        vm.startPrank(user1);
        payments.makePayment(user2, amount, "Test", "Test Payment");
        vm.stopPrank();
    }

    function testGetPaymentsByAddress() public {
        uint256 amount = 100 * 10**6;
        
        vm.startPrank(user1);
        payments.makePayment(user2, amount, "Test1", "Payment 1");
        payments.makePayment(user2, amount, "Test2", "Payment 2");
        vm.stopPrank();

        uint256[] memory user1Payments = payments.getPaymentsByAddress(user1);
        assertEq(user1Payments.length, 2);
        assertEq(user1Payments[0], 0);
        assertEq(user1Payments[1], 1);
    }
}