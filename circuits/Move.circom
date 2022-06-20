include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template Move() {
    signal input playerPieces[40][3];
    signal input opponentPieces[40][3];

    // (x, y) coordinates of piece to be moved on the board and its rank
    signal input pieceToMove[3];
    // (x, y) coordinates of piece after being moved
    signal input movedPiece[3];

    // Piece can only move up (0), down (1), left (2), right (3)
    // TODO: Whether this causes a piece to be outside of the game board can be checked in the Solidity contracts or in the ZKP
    // should check whether the difference in gas costs is worth the difference in proving time. For now we are assuming the circuits assumes that the check is done in Solidity
    // TODO 2: A Scout can move any distance but we want to get the game working without this extra logic just yet
    // NOTE: This "move" signal was used previously but can mostly be rid of
    signal input move;

    // User held secret that prevents others from brute forcing the board's configuration
    signal input trapdoor;
    signal input solnHash;

    // If a piece was attacked return its rank, an out of bound rank if there was an error, or 0 if the piece moved to a blank spot
    // TODO: perhaps will need to return more than just rank though, will also need to know whether it was P1 or P2 piece that won
    signal output rank;

    var ranks[12] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12];
        
    component collisionCheckerPlayer[80]; 
    var k = 0;
    for (var i = 0; i < 40; i++) {
        collisionCheckerPlayer[k] = IsEqual();
        collisionCheckerPlayer[k].in[0] <== playerPieces[i][0];
        collisionCheckerPlayer[k].in[1] <== movedPiece[0];
        
        collisionCheckerPlayer[k + 1] = IsEqual();
        collisionCheckerPlayer[k + 1].in[0] <== playerPieces[i][1];
        collisionCheckerPlayer[k + 1].in[1] <== movedPiece[1];

        collisionCheckerPlayer[k].out * collisionCheckerPlayer[k+1].out === 0;

        k += 2;
    }

    component collisionCheckerOpponent[80]; 
    k = 0;
    for (var i = 0; i < 40; i++) {
        collisionCheckerOpponent[k] = IsEqual();
        collisionCheckerOpponent[k].in[0] <== opponentPieces[i][0];
        collisionCheckerOpponent[k].in[1] <== movedPiece[0];
        
        collisionCheckerOpponent[k + 1] = IsEqual();
        collisionCheckerOpponent[k + 1].in[0] <== opponentPieces[i][1];
        collisionCheckerOpponent[k + 1].in[1] <== movedPiece[1];

        collisionCheckerOpponent[k].out * collisionCheckerOpponent[k+1].out === 0;

        k += 2;
    }

    component hasher = MiMCSponge(241, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+1] <== playerPieces[pieceIndex][i % 3];
    }

    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+121] <== opponentPieces[pieceIndex][i % 3];
    }

    solnHash === hasher.outs[0];

}

component main = Move();