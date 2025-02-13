// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TransparentPayments is ReentrancyGuard, Ownable {
    // USDC token contract
    IERC20 public immutable usdc;

    // Struct to store payment details
    struct Payment {
        address from;
        address to;
        uint256 amount;
        string category;
        string description;
        uint256 timestamp;
    }

    // Array to store all payments
    Payment[] public payments;

    // Mapping to track payments by address
    mapping(address => uint256[]) public paymentsByAddress;

    // Events
    event PaymentMade(
        uint256 indexed paymentId,
        address indexed from,
        address indexed to,
        uint256 amount,
        string category,
        string description,
        uint256 timestamp
    );

    constructor(address _usdcAddress) {
        require(_usdcAddress != address(0), "Invalid USDC address");
        usdc = IERC20(_usdcAddress);
    }

    // Make a payment with optional category and description
    function makePayment(
        address _to,
        uint256 _amount,
        string memory _category,
        string memory _description
    ) external nonReentrant {
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Payment amount must be greater than 0");
        
        // Transfer USDC from sender to recipient
        require(usdc.transferFrom(msg.sender, _to, _amount), "USDC transfer failed");

        // Create new payment
        uint256 paymentId = payments.length;
        payments.push(Payment({
            from: msg.sender,
            to: _to,
            amount: _amount,
            category: _category,
            description: _description,
            timestamp: block.timestamp
        }));

        // Update payment indices
        paymentsByAddress[msg.sender].push(paymentId);
        paymentsByAddress[_to].push(paymentId);

        // Emit event
        emit PaymentMade(
            paymentId,
            msg.sender,
            _to,
            _amount,
            _category,
            _description,
            block.timestamp
        );
    }

    // Get payment details by ID
    function getPayment(uint256 _paymentId) external view returns (
        address from,
        address to,
        uint256 amount,
        string memory category,
        string memory description,
        uint256 timestamp
    ) {
        require(_paymentId < payments.length, "Payment ID does not exist");
        Payment memory payment = payments[_paymentId];
        return (
            payment.from,
            payment.to,
            payment.amount,
            payment.category,
            payment.description,
            payment.timestamp
        );
    }

    // Get all payment IDs for an address
    function getPaymentsByAddress(address _address) external view returns (uint256[] memory) {
        return paymentsByAddress[_address];
    }

    // Get total number of payments
    function getTotalPayments() external view returns (uint256) {
        return payments.length;
    }

    // Get multiple payments by ID range
    function getPaymentRange(uint256 _startId, uint256 _endId) external view returns (Payment[] memory) {
        require(_startId <= _endId, "Invalid range");
        require(_endId < payments.length, "End ID out of range");

        uint256 rangeLength = _endId - _startId + 1;
        Payment[] memory paymentRange = new Payment[](rangeLength);

        for (uint256 i = 0; i < rangeLength; i++) {
            paymentRange[i] = payments[_startId + i];
        }

        return paymentRange;
    }
}