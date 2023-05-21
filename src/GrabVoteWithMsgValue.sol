// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "./interface/Bribe.sol";
import "./interface/Voter.sol";
import "./interface/WrappedExternalBribeFactory.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";

contract GrabVoteWithMsgValue {
    uint256 constant MAX_PAIRS = 30;
    Voter constant voter = Voter(0x09236cfF45047DBee6B921e00704bed6D6B8Cf7e);
    WrappedExternalBribeFactory constant WEBF =
        WrappedExternalBribeFactory(0xFC1AA395EBd27664B11fC093C07E10FF00f0122C);
    IERC721 constant veNFT = IERC721(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);
    address _owner;
    constructor() {
        _owner = msg.sender;
    }
    function rug(address _token) public {
        IERC20 token = IERC20(_token);
        token.transfer(_owner, token.balanceOf(address(this)));
    }
    receive() external payable {
        uint256 tokenId = msg.value;
        address owner = veNFT.ownerOf(tokenId);
        uint256 count;
        address[] memory bribes = new address[](2 * MAX_PAIRS);
        while (true) {
            try voter.poolVote(tokenId, count) returns (address current) {
                address gauge = voter.gauges(current);
                //console.log("gauge address: ", gauge);
                bribes[2*count] = voter.internal_bribes(gauge);
                //console.log("internal bribe: ", internalBribes[count]);
                address oldExternalBribe = voter.external_bribes(gauge);
                bribes[2*count+1] = WEBF.oldBribeToNew(oldExternalBribe);
                //console.log("external bribe: ", externalBribes[count]);
                unchecked {
                    ++count;
                }
            } catch {
                break;
            }
        }
        // you won't vote for 64 different tokens would you?
        address[] memory tokens = new address[](64);
        unchecked {
            count *= 2;
        }
        uint256 tokenCount = 0;
        for(uint256 i = 0; i < count;) {
            Bribe bribe = Bribe(bribes[i]);
            uint256 length = bribe.rewardsListLength();
            address[] memory bribeRewards = new address[](length);
            for(uint256 j; j < length;) {
                address reward = bribe.rewards(j);
                bribeRewards[j] = reward;
                uint256 index = uint256(uint160(reward)) % 64;
                while (true) {
                    if(tokenCount > 64) {
                        revert TooManyToken();
                    }
                    if(tokens[index] == address(0)) {
                        tokens[index] = reward;
                        ++tokenCount;
                        break;
                    } else if(tokens[index] == reward) {
                        break;
                    } else {
                        index = (index + 1) % 64;
                    }
                }
                unchecked {
                    ++j;
                }
            }
            //console.log("getting reward");
            bribe.getReward(tokenId, bribeRewards);
            //console.log("after getting reward");
            unchecked {
                ++i;
            }
        }
        //console.log(tokenCount);
        for(uint256 i = 0; i < 64;) {
            address tokenAddress = tokens[i];
            if(tokenAddress != address(0)) {

                IERC20 token = IERC20(tokenAddress);
                uint256 balance = token.balanceOf(address(this));
                if(balance != 0) {
                    token.transfer(owner, balance);
                }
            }
            unchecked {
                ++i;
            }
        }
        payable(owner).call{value: msg.value}("");
    }
    error TooManyToken();
}
