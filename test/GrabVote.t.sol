pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GrabVote.sol";
import "../src/interface/VotingEscrow.sol";
import {IERC20Metadata as ERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract GrabVoteTest is Test {
    GrabVote public gv;
    string OPTIMISM_RPC = vm.envString("OPTIMISM_RPC");
    uint256 optimismFork;
    mapping (address => bool) tokenAlreadyOnList;
    mapping (address => uint256) balanceBefore;
    address[] tokens = new address[](0);
    function setUp() public {
        optimismFork = vm.createSelectFork(OPTIMISM_RPC, 99589740);
        gv = new GrabVote();
    }
    function testGetPoolVotes() public view {
        (address[] memory i, address[] memory e) = gv.getPoolVotes(63);
        for(uint j = 0; j < i.length; j++) {
            if(i[j] != address(0)) {console.log("internal ", i[j]);
            console.log("external ", e[j]);}
        }
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
        veNFT.approve(address(gv), 63);
        gv.claim(63);
        for (uint j = 0; j < tokens.length; j++) {
            ERC20 token = ERC20(tokens[j]);
            console.log(string.concat(token.symbol(), " balance before: ") , balanceBefore[tokens[j]], "balance after: ", token.balanceOf(owner));
            //assertGt(token.balanceOf(owner), balanceBefore[tokens[j]]);
            assertTrue(token.balanceOf(address(gv)) == 0);
        }
    }
}