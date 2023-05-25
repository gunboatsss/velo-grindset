pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GrabVote.sol";
import "../src/GrabVoteWithMsgValue.sol";
import "../src/interface/VotingEscrow.sol";
import "forge-std/StdUtils.sol";
import {IERC20Metadata as ERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract GrabVoteWithMsgValueTest is Test {
    GrabVoteWithMsgValue public gvwmv;
    GrabVote public gv;
    string OPTIMISM_RPC = vm.envString("OPTIMISM_RPC");
    uint256 optimismFork;
    mapping (address => bool) tokenAlreadyOnList;
    mapping (address => uint256) balanceBefore;
    address[] tokens = new address[](0);
    function setUp() public {
        optimismFork = vm.createSelectFork(OPTIMISM_RPC, 99589740);
        gv = new GrabVote();
        gvwmv = new GrabVoteWithMsgValue();
    }
    function testClaim() public {
        VotingEscrow veNFT = VotingEscrow(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);
        address owner = veNFT.ownerOf(63);
        (address[] memory i, address[] memory e) = gv.getPoolVotes(63);
        for(uint256 j = 0; j < i.length; j++) {
            if(i[j] != address(0)) {
                address[] memory bribeToken = gv.getRewardsArray(i[j]);
                for (uint k = 0; k < bribeToken.length; k++) {
                    if(!tokenAlreadyOnList[bribeToken[k]]) {
                        tokenAlreadyOnList[bribeToken[k]] = true;
                        tokens.push(bribeToken[k]);
                    }   
                }
            }
            if(e[j] != address(0)) {
                address[] memory bribeToken = gv.getRewardsArray(e[j]);
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
        veNFT.approve(address(gvwmv), 63);
        (bool succ, bytes memory reason) = address(gvwmv).call{value: 63}("");
        console.log(string(reason));
        assertTrue(succ);
        for (uint j = 0; j < tokens.length; j++) {
            ERC20 token = ERC20(tokens[j]);
            console.log(string.concat(token.symbol(), " balance before: "), balanceBefore[tokens[j]], "balance after: ", token.balanceOf(owner));
            //assertGt(token.balanceOf(owner), balanceBefore[tokens[j]]);
            assertTrue(token.balanceOf(address(gvwmv)) == 0);
            assertTrue(address(gvwmv).balance == 0);
        }
    }
    function testOwnership() public {
        address dai = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        deal(dai, address(gvwmv), 69e18);
        vm.startPrank(address(1));
        vm.expectRevert();
        gvwmv.rug(dai);
        vm.expectRevert();
        gvwmv.transferOwnership(address(2));
        vm.expectRevert();
        gvwmv.acceptOwnership();
        vm.expectRevert();
        gvwmv.renounceOwnership();
        vm.stopPrank();
        gvwmv.rug(dai);
        assertTrue(IERC20(dai).balanceOf(address(gvwmv)) == 0);
        gvwmv.transferOwnership(address(2));
        vm.startPrank(address(2));
        gvwmv.acceptOwnership();
        assertTrue(gvwmv.owner() == address(2));
        assertTrue(gvwmv.pendingOwner() == address(0));
        gvwmv.renounceOwnership();
        assertTrue(gvwmv.owner() == address(0));
    }
}