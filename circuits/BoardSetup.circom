include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

// Thinking about a separate Piece template, but not sure what the output would be other than rank which can be specified as inputs anyway
// template Piece() {
//     // All booleans as 0 or 1
//     signal input isBomb;
//     signal input isScout;
//     signal input isMiner;
//     signal input isSpy;

//     signal input rank;
// }

template PieceInSetupRange() {
    signal input x;
    signal input y;
    // TODO: wanted to use this, but might need to switch to a mux
    // get this error when using it There are constraints depending on the value of the condition and it can be unknown during the constraint generation phase
    signal input isPlayerOne;

    // Check that the x coordinates are < 10
    component xLessThan = LessThan(4);
    xLessThan.in[0] <== x;
    xLessThan.in[1] <== 10;

    // Check that the y coordinates are < 4
    component yLessThan = LessThan(4);
    yLessThan.in[0] <== y;
    // The placement of the pieces changes based on whether it is player one or two
    // Player one uses the bottom 4 rows and player two uses the top 4
    component pieceLessThanMuxer = Mux1();
    pieceLessThanMuxer.s <== isPlayerOne;
    pieceLessThanMuxer.c[0] <== 4;
    pieceLessThanMuxer.c[1] <== 10;
    yLessThan.in[1] <== pieceLessThanMuxer.out;

    xLessThan.out * yLessThan.out === 1;

    // Need to check that player two has not placed pieces below the top 4 rows of the board
    component yGreaterEqThan = GreaterEqThan(4);
    yGreaterEqThan.in[0] <== y;
    yGreaterEqThan.in[1] <== 6;
    
    component pieceGreaterEqThanMuxer = Mux1();
    pieceGreaterEqThanMuxer.s <== isPlayerOne;
    pieceGreaterEqThanMuxer.c[0] <== 1;
    pieceGreaterEqThanMuxer.c[1] <== yGreaterEqThan.out;

    pieceGreaterEqThanMuxer.out === 1;
}

// Checks whether the placement of pieces on the board is valid. 
// The board is 10 x 10 with two players occupying four rows on both ends with two empty rows in the middle
template BoardSetup() {
    // The rows are each piece represented by its x and y coordinates
    // TODO: perhaps change to create a component piece that has a variables determining the rank, whether a piece is a bomb, miner, or scout, etc.
    // Previous way I was specifying stuff
    // signal input bombs[6][3];
    // signal input marshal[2];
    // signal input general[2];
    // signal input colonel[2][2];
    // signal input major[3][2];
    // signal input lieutenant[4][2];
    // signal input sergeant[4][2];
    // signal input miner[5][2];
    // signal input scout[8][2];
    // signal input spy[1][2];

    // The rows are a piece represented by its x and y coordinates, and then its rank
    // Every piece is represented by its rank 1-10. Bombs have a rank of 11 and can only be defeated by miners.
    // All game logic is done with ranks, which is fine as all the special pieces (Bomb, Miner, Scout, Spy) have a unique rank not shared by other generic pieces
    // More information on the game rules can be found here: https://www.hasbro.com/common/instruct/Stratego.PDF
    signal input piecesPlayerOne[40][3];
    signal input piecesPlayerTwo[40][3];

    signal input trapdoor;

    signal output hash;

    var bombCounter;
    var marshalCounter;
    var generalCounter; 
    var colonelCounter;
    var majorCounter;
    var lieutenantCounter;
    var sergeantCounter;
    var minerCounter;
    var scoutCounter;
    var spyCounter;

    component pieceInRangeValidatorP1[40];
    for (var i = 0; i < 40; i++) {
        pieceInRangeValidatorP1[i] = PieceInSetupRange();
        pieceInRangeValidatorP1[i].x <== piecesPlayerOne[i][0];
        pieceInRangeValidatorP1[i].y <== piecesPlayerOne[i][1];
        pieceInRangeValidatorP1[i].isPlayerOne <== piecesPlayerOne[i][2];
    }

}

component main = BoardSetup();