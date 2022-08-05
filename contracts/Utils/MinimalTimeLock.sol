//SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "../Access/JellyAccessControls.sol";
import "../OpenZeppelin/utils/Context.sol";

// Modified from https://etherscan.io/address/0x6d903f6003cca6255d85cca4d3b5e5146dc33925#code and https://github.com/boringcrypto/dictator-dao/blob/main/contracts/DictatorDAO.sol#L225
contract MinimalTimeLock is  Context, JellyAccessControls {    
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data, uint256 eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data);

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant DELAY = 2 days;
    mapping(bytes32 => uint256) public queuedTransactions;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    function queueTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public returns (bytes32) {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "queueTransaction: Must have operator role");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = block.timestamp + DELAY;
        queuedTransactions[txHash] = eta;

        emit QueueTransaction(txHash, target, value, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "cancelTransaction: Must have operator role");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        queuedTransactions[txHash] = 0;

        emit CancelTransaction(txHash, target, value, data);
    }

    function executeTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public payable returns (bytes memory) {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "executeTransaction: Must have operator role");

        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = queuedTransactions[txHash];
        require(block.timestamp >= eta, "Too early");
        require(block.timestamp <= eta + GRACE_PERIOD, "Tx stale");

        queuedTransactions[txHash] = 0;

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(data);
        require(success, "Tx reverted :(");

        emit ExecuteTransaction(txHash, target, value, data);

        return returnData;
    }
}