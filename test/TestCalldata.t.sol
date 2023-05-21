pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "../src/TestCalldata.sol";

contract TestCalldataTest is Test {
    TestCalldata public t;
    function setUp() public {
        t = new TestCalldata();
    }
    function testOneByte() public {
        bytes1 by = 0x01;
        //console.log(by);
        (bool succ, bytes memory reason) = address(t).call{value: 0}(abi.encode(by));
    }
}