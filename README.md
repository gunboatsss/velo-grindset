# velo-grindset
A attempt in making Velodrome (and its fork) reward claiming cheaper by cutting calldata

# what?
This is smart contract to make velodrome fee/bribe cheaper to claim in one transaction by encoding nft id into ether balance in transaction and retrieving vote data from the chain, this is cheap because Optimistic Rollup calldata is very expensive compared to execution fee.
