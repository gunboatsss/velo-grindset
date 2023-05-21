// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import "forge-std/console.sol";

contract TestCalldata {
    constructor() {
        
    }
    fallback (bytes calldata input) external payable returns (bytes memory output) {
        console.log("calldata length", input.length);
        console.logBytes(input);
    }
}