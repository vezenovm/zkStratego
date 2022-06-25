pragma circom 2.0.4;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mux1.circom";

// TODO: probably can separate this circuit so that the mux is not needed, and only call the specific template for player one or player two respectively
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