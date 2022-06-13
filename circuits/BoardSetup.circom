include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template PieceInSetupRange() {
    signal input x;
    signal input y;
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
    // TODO: perhaps change to create a component piece that has a variables determining the rank, whether a piece is a bomb, miner, or scout, etc.

    // The rows are a piece represented by its x and y coordinates, and then its rank
    // Every ranked piece is represented by its rank 1-10. Bombs have a rank of 11 and can only be defeated by miners. The Flag has a rank of 0.
    // All game logic is done with ranks, which is fine as all the special pieces (Bomb, Miner, Scout, Spy) have a unique rank not shared by other generic pieces
    // More information on the game rules can be found here: https://www.hasbro.com/common/instruct/Stratego.PDF
    signal input piecesPlayerOne[40][3];
    signal input piecesPlayerTwo[40][3];

    signal input trapdoor;

    signal output solnHashOut;

    // Need to do multi mux to check that the game board has the correct amount of players of each rank. Can't compare amounts of certain input as it is 
    // unkown at compile time
    // Perhaps it would be easier to switch to the separate variables representing each type of player and then the ranks are simply hardcoded
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

    // Could instead use this hardcoded ranks array, and a set way the pieces must be specified in the inputs
    // No need for the counters then as the pieces must be in rank order
    var ranks[12] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];

    component pieceInRangeValidatorP1[40];
    component pieceInRangeValidatorP2[40];
    for (var i = 0; i < 40; i++) {
        // Check that each player has their pieces only on the closest four rows to their starting side
        pieceInRangeValidatorP1[i] = PieceInSetupRange();
        pieceInRangeValidatorP1[i].x <== piecesPlayerOne[i][0];
        pieceInRangeValidatorP1[i].y <== piecesPlayerOne[i][1];
        pieceInRangeValidatorP1[i].isPlayerOne <== 1;

        pieceInRangeValidatorP2[i] = PieceInSetupRange();
        pieceInRangeValidatorP2[i].x <== piecesPlayerTwo[i][0];
        pieceInRangeValidatorP2[i].y <== piecesPlayerTwo[i][1];
        pieceInRangeValidatorP2[i].isPlayerOne <== 0;

        // Check that the pieces included are of the correct rank and in order
        if (i < 6) {
            ranks[0] === piecesPlayerOne[i][2];
            ranks[0] === piecesPlayerTwo[i][2];
        } else if (i == 6) {
            ranks[1] === piecesPlayerOne[i][2];
            ranks[1] === piecesPlayerTwo[i][2];
        } else if (i == 7) {
            ranks[2] === piecesPlayerOne[i][2];
            ranks[2] === piecesPlayerTwo[i][2];
        } else if (i > 7 && i <= 9) {
            ranks[3] === piecesPlayerOne[i][2];
            ranks[3] === piecesPlayerTwo[i][2];
        } else if (i >= 10 && i <= 12) {
            ranks[4] === piecesPlayerOne[i][2];
            ranks[4] === piecesPlayerTwo[i][2];
        } else if (i >= 13 && i <= 16) {
            ranks[5] === piecesPlayerOne[i][2];
            ranks[5] === piecesPlayerTwo[i][2];
        } else if (i >= 17 && i <= 20) {
            ranks[6] === piecesPlayerOne[i][2];
            ranks[6] === piecesPlayerTwo[i][2];
        } else if (i >= 21 && i <= 24) {
            ranks[7] === piecesPlayerOne[i][2];
            ranks[7] === piecesPlayerTwo[i][2];
        } else if (i >= 25 && i <= 29) {
            ranks[8] === piecesPlayerOne[i][2];
            ranks[8] === piecesPlayerTwo[i][2];
        } else if (i >= 30 && i <= 37) {
            ranks[9] === piecesPlayerOne[i][2];
            ranks[9] === piecesPlayerTwo[i][2];
        } else if (i == 38) {
            ranks[10] === piecesPlayerOne[i][2];
            ranks[10] === piecesPlayerTwo[i][2];
        } else if (i == 39) {
            ranks[11] === piecesPlayerOne[i][2];
            ranks[11] === piecesPlayerTwo[i][2];
        }
    }

    // TODO: add in collision check for own players pieces

    component hasher = MiMCSponge(241, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+1] <== piecesPlayerOne[pieceIndex][i % 3];
    }

    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+121] <== piecesPlayerTwo[pieceIndex][i % 3];
    }

    solnHashOut <== hasher.outs[0];
}

component main = BoardSetup();