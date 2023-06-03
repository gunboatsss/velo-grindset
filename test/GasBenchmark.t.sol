// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import { GrabVote } from "../src/GrabVote.sol";
import { GrabVoteWithMsgValue } from "../src/GrabVoteWithMsgValue.sol";
import { ChronosGrabVote } from "../src/ChronosGrabVote.sol";
import { ChronosGrabVoteV2 } from "../src/ChronosGrabVoteV2.sol";
import "../src/interface/VotingEscrow.sol";
import "forge-std/Test.sol";

contract GasBenchmark is Test {
    GrabVote grabVote;
    GrabVoteWithMsgValue grabVoteWithMsgValue;
    ChronosGrabVote chronosGrabVote;
    ChronosGrabVoteV2 chronosGrabVoteV2;
    uint256 arbitrumOne;
    uint256 optimism;
    string ARB1_RPC = vm.envString("ARB1_RPC");
    string OPTIMISM_RPC = vm.envString("OPTIMISM_RPC");
    uint256 optimismBlockToFork = 99589740;
    uint256 arbitrumBlockToFork = 97045041;
    uint256 velodromeNftId = 63;
    uint256 chronosNftId = 2775;
    VotingEscrow velodrome;
    VotingEscrow chronos;
    function setUp() public {
        optimism = vm.createSelectFork(OPTIMISM_RPC, optimismBlockToFork);
        velodrome = VotingEscrow(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);
        address owner = velodrome.ownerOf(velodromeNftId);
        grabVote = new GrabVote();
        grabVoteWithMsgValue = new GrabVoteWithMsgValue();
        vm.startPrank(owner);
        velodrome.approve(address(grabVote), velodromeNftId);
        velodrome.approve(address(grabVoteWithMsgValue), velodromeNftId);
        vm.stopPrank();
        arbitrumOne = vm.createSelectFork(ARB1_RPC, arbitrumBlockToFork);
        chronos = VotingEscrow(0x9A01857f33aa382b1d5bb96C3180347862432B0d);
        owner = chronos.ownerOf(chronosNftId);
        chronosGrabVoteV2 = new ChronosGrabVoteV2();
        chronosGrabVote = new ChronosGrabVote();
        vm.startPrank(owner);
        chronos.approve(address(chronosGrabVote), chronosNftId);
        chronos.approve(address(chronosGrabVoteV2), chronosNftId);
        vm.stopPrank();
    }
    function testVeloGrabVoteClaim() public {
        vm.selectFork(optimism);
        grabVote.claim(velodromeNftId);
    }
    function testVeloGrabVoteWithMsgValueClaim() public {
        vm.selectFork(optimism);
        address(grabVoteWithMsgValue).call{value: velodromeNftId}("");
    }
    function testChronosGrabVoteClaim() public {
        vm.selectFork(arbitrumOne);
        address(chronosGrabVote).call{value: chronosNftId}("");
    }
    function testChronosGrabVoteV2Claim() public {
        vm.selectFork(arbitrumOne);
        address(chronosGrabVoteV2).call{value: chronosNftId}("");
    }
}