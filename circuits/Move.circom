include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template RangeProof(n) {
    assert(n <= 252);
    signal input in; // this is the number to be proved inside the range
    signal input range[2]; // the two elements should be the range, i.e. [lower bound, upper bound]
    signal output out;

    component low = LessEqThan(n);
    component high = GreaterEqThan(n);

    // check whether the input is greater than or equal to the lower bound
    high.in[0] <== in;
    high.in[1] <== range[0];
    
    // check whether the input is less than or equal to the upper bound
    low.in[0] <== in;
    low.in[1] <== range[1];

    out <== high.out * low.out;
 }

template Move() {
    // TODO: look into more if we need to check that the new board being generated matches the previous one except for the one piece. 
    // might need to pass in pieces from the contract and removes the ranks
    signal input playerPiecesBeforeMove[40][3];
    // New hash that will set the game board
    
    // signal input previousHash;
    signal input playerPiecesAfterMove[40][3];

    // The player only knows the locations of the opponent pieces but not necessarily their rankings
    signal input opponentPieces[40][2];

    // (x, y) coordinates of piece to be moved on the board and its rank
    signal input pieceToMove[2];

    // (x, y) coordinates of piece after being moved
    signal input movedPiece[2];

    // User held secret that prevents others from brute forcing the board's configuration
    signal input trapdoor;
    signal input solnHash;

    component xRangeProof = RangeProof(5);
    xRangeProof.range[0] <== pieceToMove[0] - 1;
    xRangeProof.range[1] <== pieceToMove[0] + 1;
    xRangeProof.in <== movedPiece[0];
    assert(xRangeProof.out);

    component yRangeProof = RangeProof(5);
    yRangeProof.range[0] <== pieceToMove[1] - 1;
    yRangeProof.range[1] <== pieceToMove[1] + 1;
    yRangeProof.in <== movedPiece[1];
    assert(yRangeProof.out);

    component xIsEqual = IsEqual();
    xIsEqual.in[0] <== pieceToMove[0];
    xIsEqual.in[1] <== movedPiece[0];

    component yIsEqual = IsEqual();
    yIsEqual.in[0] <== pieceToMove[1];
    yIsEqual.in[1] <== movedPiece[1];

    component xIsEqualMux = MultiMux1(1);
    xIsEqualMux.c[0][0] <== yIsEqual.out;
    xIsEqualMux.c[0][1] <== 0;
    xIsEqualMux.s <== xIsEqual.out;
    // If x coordinate equals the previous placement the y coordinate should differ
    xIsEqualMux.out[0] === 0;

    component xIsNotEqualMux = MultiMux1(1);
    xIsNotEqualMux.c[0][0] <== 1;
    xIsNotEqualMux.c[0][1] <== yIsEqual.out;
    xIsNotEqualMux.s <== xIsEqual.out;
    // If x coordinate is not the same, the y coordinate should be the same as previously
    xIsNotEqualMux.out[0] === 1;

    // TODO: add check the player is not trying to move a bomb or flag piece as they are immovable 
    component collisionCheckerPlayer[80]; 
    var k = 0;
    for (var i = 0; i < 40; i++) {
        collisionCheckerPlayer[k] = IsEqual();
        collisionCheckerPlayer[k].in[0] <== playerPiecesBeforeMove[i][0];
        collisionCheckerPlayer[k].in[1] <== movedPiece[0];
        
        collisionCheckerPlayer[k + 1] = IsEqual();
        collisionCheckerPlayer[k + 1].in[0] <== playerPiecesBeforeMove[i][1];
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

    component hasher = MiMCSponge(121, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var index = i \ 3;
        hasher.ins[i+1] <== playerPiecesAfterMove[index][i % 3];
    }

    solnHash === hasher.outs[0];

}

component main { public [solnHash, opponentPieces, pieceToMove, movedPiece] } = Move();