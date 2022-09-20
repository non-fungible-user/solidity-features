import { expect } from "chai";
import { ethers } from "hardhat";
const { MerkleTree } = require("merkletreejs");
// import { keccak256 } from "@ethersproject/keccak256";
const { keccak256 } = ethers.utils;
function padBuffer(addr: any) {
  return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
}

describe("VerifyMerkleTrees", function () {
  it("Check merkle tree", async function () {
    const accounts = await ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);
    const notWhitelisted = accounts.slice(5, 10);

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();

    const VerifyMerkleTrees = await ethers.getContractFactory(
      "VerifyMerkleTrees"
    );

    const contract = await VerifyMerkleTrees.deploy(merkleRoot);
    await contract.deployed();

    const merkleProof = tree.getHexProof(padBuffer(whitelisted[0].address));
    const invalidMerkleProof = tree.getHexProof(
      padBuffer(notWhitelisted[0].address)
    );

    await contract.whitelistMint(merkleProof);

    await expect(
      contract.connect(notWhitelisted[0]).whitelistMint(invalidMerkleProof)
    ).to.be.revertedWith("Invalid merkle proof");

    expect(await contract.whiteListMinted(whitelisted[0].address)).to.equal(
      true
    );

    expect(await contract.whiteListMinted(notWhitelisted[0].address)).to.equal(
      false
    );
  });
});
