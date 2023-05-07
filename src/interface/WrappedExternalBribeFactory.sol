pragma solidity ^0.8.10;

interface WrappedExternalBribeFactory {
    function createBribe(address existing_bribe) external returns (address);
    function last_bribe() external view returns (address);
    function oldBribeToNew(address) external view returns (address);
    function voter() external view returns (address);
}
