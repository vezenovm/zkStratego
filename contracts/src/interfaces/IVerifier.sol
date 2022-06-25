// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// Groth16 Verifier
// interface IBoardSetupVerifier {
//     function verifyProof(
//         uint256[2] memory a,
//         uint256[2][2] memory b,
//         uint256[2] memory c,
//         uint256[1] memory input
//     ) external view returns (bool r);
// }

interface IBoardSetupVerifier {
    function verifyProof(
        bytes memory proof, 
        uint[81] memory pubSignals
    ) external view returns (bool r);
}

interface IJoinGameVerifier {
    function verifyProof(
        bytes memory proof,
        uint[81] memory input
    ) external view returns (bool r);
}

interface IMoveVerifier {
    function verifyProof(
        bytes memory proof,
        uint256[85] memory input
    ) external view returns (bool r);
}

interface IAttackVerifier {
    function verifyProof(
        bytes memory proof,
        uint256[9] memory input
    ) external view returns (bool r);
}

