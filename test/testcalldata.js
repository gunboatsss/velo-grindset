const { expect } = require('chai');
const { ethers } = require('hardhat');
const hre = require('hardhat');

describe('calldata', function () {
    it('something', async function () {
        const [owner] = await ethers.getSigners();
        const tcd = await hre.ethers.getContractFactory('TestCalldata');
        const inst = await tcd.deploy();
        const tx = await owner.sendTransaction({
            to: inst.address,
            data: '0x01'
        });
        expect(true);
    }) 
})