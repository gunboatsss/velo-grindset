pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GrabVote.sol";
import "../src/interface/VotingEscrow.sol";

contract GrabVoteTest is Test {
    GrabVote public gv;

    string OPTIMISM_RPC = vm.envString("OPTIMISM_RPC");
    uint256 optimismFork;

    function setUp() public {
        console.log(OPTIMISM_RPC);
        optimismFork = vm.createSelectFork(OPTIMISM_RPC);
        gv = new GrabVote();
    }
    function testGetPoolVotes() public view {
        (address[] memory i, address[] memory e) = gv.getPoolVotes(63);
        for(uint j = 0; j < i.length; j++) {
            console.log("internal ", i[j]);
            console.log("external ", e[j]);
        }
    }
    function testClaim() public {
        VotingEscrow veNFT = VotingEscrow(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);
        address owner = veNFT.ownerOf(63);
        vm.prank(owner);
        veNFT.approve(address(gv), 63);
        gv.claim(63);
    }
}