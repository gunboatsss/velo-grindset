// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "./interface/Bribe.sol";
import "./interface/Voter.sol";
import "./interface/WrappedExternalBribeFactory.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract GrabVote {
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
    function getPoolVotes(
        uint256 _tokenId
    )
        public
        view
        returns (
            address[] memory,
            address[] memory
        )
    {
        address[] memory _internalBribes = new address[](MAX_PAIRS);
        address[] memory _externalBribes = new address[](MAX_PAIRS);
        uint256 count = 0;
        bool ended = false;
        while (!ended) {
            try voter.poolVote(_tokenId, count) returns (address current) {
                address gauge = voter.gauges(current);
                //console.log("gauge address: ", gauge);
                _internalBribes[count] = voter.internal_bribes(gauge);
                //console.log("internal bribe: ", internalBribes[count]);
                address oldExternalBribe = voter.external_bribes(gauge);
                _externalBribes[count] = WEBF.oldBribeToNew(oldExternalBribe);
                //console.log("external bribe: ", externalBribes[count]);
                count += 1;
            } catch {
                ended = true;
            }
        }
        return (_internalBribes, _externalBribes);
    }
    function getRewardsArray(address _bribe) public view returns (address[] memory) {
        Bribe bribe = Bribe(_bribe);
        uint256 length = bribe.rewardsListLength();
        address[] memory rewards = new address[](length);
        for (uint i = 0; i < length; i++) {
           rewards[i] = bribe.rewards(i); 
        }
        return rewards;
    }
    function getRewards(uint256 _tokenId, address _bribe) internal {
        address owner = veNFT.ownerOf(_tokenId);
        Bribe bribe = Bribe(_bribe);
        address[] memory rewards = getRewardsArray(_bribe);
        bribe.getReward(_tokenId, rewards);
        for (uint i = 0; i < rewards.length; i++) {
            IERC20 token = IERC20(rewards[i]);
            token.transfer(owner, token.balanceOf(address(this)));
        }
    }
    function claim(uint256 _tokenId) external {
        (address[] memory internalBribes, address[] memory externalBribes) = getPoolVotes(_tokenId);
        for(uint256 i = 0; i < internalBribes.length; i++) {
            if (internalBribes[i] == address(0)) break;
            getRewards(_tokenId, internalBribes[i]);
            getRewards(_tokenId, externalBribes[i]);
        }
    }
}
