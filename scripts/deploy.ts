import { ethers } from "hardhat";

async function main() {
  const VerifySignature = await ethers.getContractFactory("VerifySignature");
  const verifySignature = await VerifySignature.deploy();
  await verifySignature.deployed();

  console.log("VerifySignature deployed to:", verifySignature.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
