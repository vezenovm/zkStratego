include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

// Circuit logic for how an attack should be called
template Attack() {
    // Former placement of pieces before attack movement
    signal input playerPieces[40][3];
    // signal input opponentPieces[40][3];

    // (x, y) coordinates of piece to be moved on the board and its rank
    signal input pieceToMove[3];
    // TODO: need to add logic that the move has only been up, down, left, or right by one
    // (x, y) coordinates of piece after being moved
    signal input movedPiece[3];

    // Opponent piece that is being attacked
    signal input opponentPiece[3];

    // Piece can only move up (0), down (1), left (2), right (3)
    // TODO: Whether this causes a piece to be outside of the game board can be checked in the Solidity contracts or in the ZKP
    // should check whether the difference in gas costs is worth the difference in proving time. For now we are assuming the circuits assumes that the check is done in Solidity
    // TODO 2: A Scout can move any distance but we want to get the game working without this extra logic just yet
    signal input move;

    // User held secret that prevents others from brute forcing the board's configuration
    signal input trapdoor;
    signal input solnHash;

    // Result can either be a loss (0), win (1), or tie (2). Would most likely not require any output, changes how we create our contracts
    // signal input result;
    // TODO: perhaps will need to return more than just rank though, will also need to know whether it was P1 or P2 piece that won. 
    signal output rank;

    var ranks[12] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12];

    component hasher = MiMCSponge(127, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+1] <== playerPieces[pieceIndex][i % 3];
    }
    hasher.ins[121] <== movedPiece[0];
    hasher.ins[122] <== movedPiece[1];
    hasher.ins[123] <== movedPiece[2];

    hasher.ins[124] <== opponentPiece[0];
    hasher.ins[125] <== opponentPiece[1];
    hasher.ins[126] <== opponentPiece[2];

    // for (var i = 0; i < 120; i++) {
    //     var pieceIndex = i \ 3;
    //     hasher.ins[i+121] <== opponentPieces[pieceIndex][i % 3];
    // }

    solnHash === hasher.outs[0];
        
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

    component attackChecker[2];
    attackChecker[0] = IsEqual();
    attackChecker[0].in[0] <== opponentPiece[0];
    attackChecker[0].in[1] <== movedPiece[0];

    attackChecker[1] = IsEqual();
    attackChecker[1].in[0] <== opponentPiece[1];
    attackChecker[1].in[1] <== movedPiece[1];

    attackChecker[0].out * attackChecker[1].out === 1;  

    // component rankChecker[2];
    // rankChecker[0] = GreaterEqThan(5);
    // rankChecker.in[0] <== movedPiece[2];
    // rankChecker.in[1] <== opponentPiece[2];

    // Reveal opponent piece ranking
    rank <== opponentPiece[2];
}

component main = Attack();

