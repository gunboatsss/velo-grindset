const { expect } = require('chai');
const { ethers } = require('hardhat');
const hre = require('hardhat');

describe('Grindset', function () {
    it('Claim the reward', async function () {
        const tokenId = 63;
        const [owner] = await ethers.getSigners();
        const veVELO = await ethers.getContractAt('VotingEscrow', '0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26');
        const GrindsetFactory = await hre.ethers.getContractFactory('GrabVoteWithHashMap');
        const Grindset = await GrindsetFactory.deploy();
        const userAddress = await veVELO.ownerOf(tokenId);
        const user = await ethers.getSigner(ethers.utils.getAddress(userAddress));
        //console.log(user);
        await veVELO.connect(user).approve(Grindset.address, tokenId);
        const tx = await owner.sendTransaction(
            {
                to: Grindset.address,
                data: ethers.BigNumber.from(tokenId).toHexString()
            }
        )
        expect(true);
    }) 
})