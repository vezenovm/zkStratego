#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom using PLONK below

cd ../circuits

mkdir JoinGame_plonk

if [ -f ./powersOfTau28_hez_final_17.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_17.ptau
fi

echo "Compiling JoinGame.circom with PLONK..."

# compile circuit

circom JoinGame.circom --r1cs --wasm --sym -o JoinGame_plonk
snarkjs r1cs info JoinGame_plonk/JoinGame.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup JoinGame_plonk/JoinGame.r1cs powersOfTau28_hez_final_17.ptau JoinGame_plonk/circuit_0000.zkey
snarkjs zkey export verificationkey JoinGame_plonk/circuit_0000.zkey JoinGame_plonk/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier JoinGame_plonk/circuit_0000.zkey ../JoinGame_plonkVerifier.sol

cd ../..