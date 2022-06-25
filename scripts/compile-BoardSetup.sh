#!/bin/bash

cd ../circuits

mkdir BoardSetup_plonk

if [ -f ./powersOfTau28_hez_final_17.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_17.ptau
fi

echo "Compiling BoardSetup.circom with PLONK..."

# compile circuit

circom BoardSetup.circom --r1cs --wasm --sym -o BoardSetup_plonk
snarkjs r1cs info BoardSetup_plonk/BoardSetup.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup BoardSetup_plonk/BoardSetup.r1cs powersOfTau28_hez_final_17.ptau BoardSetup_plonk/circuit_0000.zkey
snarkjs zkey export verificationkey BoardSetup_plonk/circuit_0000.zkey BoardSetup_plonk/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier BoardSetup_plonk/circuit_0000.zkey ../BoardSetup_plonkVerifier.sol

cd ../..