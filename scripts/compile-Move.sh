#!/bin/bash

cd ../circuits

mkdir Move_plonk

if [ -f ./powersOfTau28_hez_final_17.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_17.ptau
fi

echo "Compiling JoinGame.circom with PLONK..."

# compile circuit

circom Move.circom --r1cs --wasm --sym -o Move_plonk
snarkjs r1cs info Move_plonk/Move.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup Move_plonk/Move.r1cs powersOfTau28_hez_final_17.ptau Move_plonk/circuit_0000.zkey
snarkjs zkey export verificationkey Move_plonk/circuit_0000.zkey Move_plonk/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier Move_plonk/circuit_0000.zkey ../Move_plonkVerifier.sol

cd ../..