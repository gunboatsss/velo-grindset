pragma solidity ^0.8.10;

interface Bribe {
    event ClaimRewards(address indexed from, address indexed reward, uint256 amount);
    event NotifyReward(address indexed from, address indexed reward, uint256 epoch, uint256 amount);

    function _ve() external view returns (address);
    function earned(address token, uint256 tokenId) external view returns (uint256);
    function getEpochStart(uint256 timestamp) external pure returns (uint256);
    function getReward(uint256 tokenId, address[] memory tokens) external;
    function getRewardForOwner(uint256 tokenId, address[] memory tokens) external;
    function isReward(address) external view returns (bool);
    function lastEarn(address, uint256) external view returns (uint256);
    function lastTimeRewardApplicable(address token) external view returns (uint256);
    function left(address token) external view returns (uint256);
    function notifyRewardAmount(address token, uint256 amount) external;
    function periodFinish(address) external view returns (uint256);
    function rewards(uint256) external view returns (address);
    function rewardsListLength() external view returns (uint256);
    function swapOutRewardToken(uint256 i, address oldToken, address newToken) external;
    function tokenRewardsPerEpoch(address, uint256) external view returns (uint256);
    function underlying_bribe() external view returns (address);
    function voter() external view returns (address);
}
