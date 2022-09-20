import { expect } from "chai";
import { ethers } from "hardhat";

describe("VerifySignature", function () {
  it("Check signature", async function () {
    const [signer, to] = await ethers.getSigners();

    const VerifySignature = await ethers.getContractFactory("VerifySignature");
    const contract = await VerifySignature.deploy();
    await contract.deployed();

    const amount = 100;
    const message = "Hello signature";
    const nonce = 42;

    const hash = await contract.getMessageHash(
      to.address,
      amount,
      message,
      nonce
    );

    const sig = await signer.signMessage(ethers.utils.arrayify(hash));
    const ethHash = await contract.getEthSignedMessageHash(hash);

    console.log("signer          ", signer.address);
    console.log("recovered signer", await contract.recoverSigner(ethHash, sig));

    expect(
      await contract.verify(
        signer.address,
        to.address,
        amount,
        message,
        nonce,
        sig
      )
    ).to.equal(true);

    expect(
      await contract.verify(
        signer.address,
        to.address,
        amount + 1,
        message,
        nonce,
        sig
      )
    ).to.equal(false);
  });
});
