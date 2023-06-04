pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/ChronosGrabVoteV2.sol";
import "../src/interface/VotingEscrow.sol";
import "forge-std/StdUtils.sol";
import {IERC20Metadata as ERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ChronosGrabVoteV2Test is Test {
    ChronosGrabVoteV2 CGV;
    string ARB1_RPC = vm.envString("ARB1_RPC");
    uint256 arbitrumOneFork;
    function setUp() public {
        arbitrumOneFork = vm.createSelectFork(ARB1_RPC);
        CGV = new ChronosGrabVoteV2();
    }
    function testFuzz_claim(uint256 id) public {
        bound(id, 1, 100);
        VotingEscrow veNFT = VotingEscrow(0x9A01857f33aa382b1d5bb96C3180347862432B0d);
        if(veNFT.balanceOfNFT(id) == 0) {
            return;
        }
        address owner = veNFT.ownerOf(id);
        vm.prank(owner);
        veNFT.approve(address(CGV), id);
        (bool succ, bytes memory reason) = address(CGV).call{value: id}("");
        console.log(string(reason));
        assertTrue(succ);
    }
}