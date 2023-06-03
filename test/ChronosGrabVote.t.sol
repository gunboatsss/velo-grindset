pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/ChronosGrabVote.sol";
import "../src/ChronosGrabVoteHelper.sol";
import "../src/interface/VotingEscrow.sol";
import "forge-std/StdUtils.sol";
import {IERC20Metadata as ERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ChronosGrabVoteTest is Test {
    ChronosGrabVote CGV;
    ChronosGrabVoteHelper helper;
    string ARB1_RPC = vm.envString("ARB1_RPC");
    uint256 arbitrumOneFork;
    uint256 forkAtBlock = 97045041;
    uint256 nftToTest = 2775;
    mapping (address => bool) tokenAlreadyOnList;
    mapping (address => uint256) balanceBefore;
    address[] tokens = new address[](0);
    function setUp() public {
        arbitrumOneFork = vm.createSelectFork(ARB1_RPC, forkAtBlock);
        CGV = new ChronosGrabVote();
        helper = new ChronosGrabVoteHelper();
    }
    function testClaim() public {
        VotingEscrow veNFT = VotingEscrow(0x9A01857f33aa382b1d5bb96C3180347862432B0d);
        address owner = veNFT.ownerOf(nftToTest);
        (address[] memory i, address[] memory e) = helper.getPoolVotes(nftToTest);
        for(uint256 j = 0; j < i.length; j++) {
            if(i[j] != address(0)) {
                address[] memory bribeToken = helper.getRewardsArray(i[j]);
                for (uint k = 0; k < bribeToken.length; k++) {
                    if(!tokenAlreadyOnList[bribeToken[k]]) {
                        tokenAlreadyOnList[bribeToken[k]] = true;
                        tokens.push(bribeToken[k]);
                    }   
                }
            }
            if(e[j] != address(0)) {
                address[] memory bribeToken = helper.getRewardsArray(e[j]);
                for (uint k = 0; k < bribeToken.length; k++) {
                    if(!tokenAlreadyOnList[bribeToken[k]]) {
                        tokenAlreadyOnList[bribeToken[k]] = true;
                        tokens.push(bribeToken[k]);
                    }   
                }
            }
        }
        for(uint256 j = 0; j < tokens.length; j++) {
            ERC20 token = ERC20(tokens[j]);
            balanceBefore[tokens[j]] = token.balanceOf(owner);
        }
        vm.prank(owner);
        veNFT.approve(address(CGV), nftToTest);
        (bool succ, bytes memory reason) = address(CGV).call{value: nftToTest}("");
        console.log(string(reason));
        assertTrue(succ);
        for (uint j = 0; j < tokens.length; j++) {
            ERC20 token = ERC20(tokens[j]);
            console.log(string.concat(token.symbol(), " balance before: "), balanceBefore[tokens[j]], "balance after: ", token.balanceOf(owner));
            //assertGt(token.balanceOf(owner), balanceBefore[tokens[j]]);
            assertTrue(token.balanceOf(address(CGV)) == 0);
            assertTrue(address(CGV).balance == 0);
        }
    }
    function testOwnership() public {
        address dai = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        deal(dai, address(CGV), 69e18);
        vm.startPrank(address(1));
        vm.expectRevert();
        CGV.rug(dai);
        vm.expectRevert();
        CGV.transferOwnership(address(2));
        vm.expectRevert();
        CGV.acceptOwnership();
        vm.expectRevert();
        CGV.renounceOwnership();
        vm.stopPrank();
        CGV.rug(dai);
        assertTrue(IERC20(dai).balanceOf(address(CGV)) == 0);
        CGV.transferOwnership(address(2));
        vm.startPrank(address(2));
        CGV.acceptOwnership();
        assertTrue(CGV.owner() == address(2));
        assertTrue(CGV.pendingOwner() == address(0));
        CGV.renounceOwnership();
        assertTrue(CGV.owner() == address(0));
    }
}