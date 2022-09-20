// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract VerifyMerkleTrees {
    bytes32 public immutable merkleRoot;

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    mapping(address => bool) public whiteListMinted;

    modifier notMinted() {
        require(!whiteListMinted[msg.sender], "Already minted");
        _;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function whitelistMint(bytes32[] calldata _merkleProof) public notMinted {
        bytes32 leaf = toBytes32(msg.sender);

        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid merkle proof"
        );

        whiteListMinted[msg.sender] = true;
    }
}
