import { ethers } from "hardhat";

async function main() {
  const bet = await ethers.deployContract("Bet", []);

  await bet.waitForDeployment();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
