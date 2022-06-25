include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

// Circuit logic for how an attack should be called
template Attack() {
    // New placement of pieces after attack movement
    // The person processing the proof is being attacked
    signal input playerPiecesWithRankAfterAttack[40][3];
    signal input playerPiecesNoRank[40][2];

    // Placement of pieces before attack movement
    signal input playerPiecesWithRankBeforeAttack[40][3];
    // TODO: need to add logic that the move has only been up, down, left, or right by one; and that piece is part of previous board orientation
    // (x, y) coordinates of piece after being moved
    signal input attackingPiece[3];

    // TODO: need to add logic that the move was part of original board
    // Piece that is being attacked 
    signal input defendingPiece[3];

    // Piece can only move up (0), down (1), left (2), right (3)
    // TODO: Whether this causes a piece to be outside of the game board can be checked in the Solidity contracts or in the ZKP
    // should check whether the difference in gas costs is worth the difference in proving time. For now we are assuming the circuits assumes that the check is done in Solidity
    // TODO 2: A Scout can move any distance but we want to get the game working without this extra logic just yet

    // User held secret that prevents others from brute forcing the board's configuration
    signal input trapdoor;

    // New hash after the opponents attack 
    signal input boardHash;

    // Result can either be a loss (0), win (1), or tie (2). Would most likely not require any output, changes how we create our contracts
    signal output result;
  
    // TODO: this is incorrect should just be checking if they are either +- 1 on the x or y axis 
    component attackChecker[2];
    attackChecker[0] = IsEqual();
    attackChecker[0].in[0] <== defendingPiece[0];
    attackChecker[0].in[1] <== attackingPiece[0];

    attackChecker[1] = IsEqual();
    attackChecker[1].in[0] <== defendingPiece[1];
    attackChecker[1].in[1] <== attackingPiece[1];

    attackChecker[0].out * attackChecker[1].out === 1;

    component hasher = MiMCSponge(121, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+1] <== playerPiecesWithRankAfterAttack[pieceIndex][i % 3];
    }
    newBoardHash === hasher.outs[0];

    component hasherBeforeAttack = MiMCSponge(121, 220, 1);
    hasherBeforeAttack.k <== 0;
    hasherBeforeAttack.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasherBeforeAttack.ins[i+1] <== playerPiecesWithRankBeforeAttack[pieceIndex][i % 3];
    }
    currentBoardHash === hasherBeforeAttack.outs[0];

    // TODO: add check for whether they are equal and there is a tie
    component rankChecker = GreaterThan(5);
    rankChecker.in[0] = defendingPiece[2];
    rankChecker.in[1] = attackingpiece[2];
    result <== rankChecker.out;
}

component main { public [newBoardHash, currentBoardHash, attackingPiece, defendingPiece] } = Attack();

