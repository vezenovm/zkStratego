pragma circom 2.0.4;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "./templates/PieceinRange.circom";

// Checks whether the placement of pieces on the board is valid. 
// The board is 10 x 10 with two players occupying four rows on both ends with two empty rows in the middle
template JoinGame() {
    // TODO: perhaps change to create a component piece that has a variables determining the rank, whether a piece is a bomb, miner, or scout, etc.

    // The rows are a piece represented by its x and y coordinates, and then its rank
    // Every ranked piece is represented by its rank 1-10. Bombs have a rank of 11 and can only be defeated by miners. The Flag has a rank of 12.
    // All game logic is done with ranks, which is fine as all the special pieces (Bomb, Miner, Scout, Spy) have a unique rank not shared by other generic pieces
    // Upon removal of a piece it can be specified with a rank of 0
    // More information on the game rules can be found here: https://www.hasbro.com/common/instruct/Stratego.PDF
    signal input playerPieces[40][3];
    // signal input piecesPlayerTwo[40][3];

    signal input trapdoor;

    signal output solnHashOut;

    // Use hardcoded ranks array, and a set way the pieces must be specified in the inputs
    // No need for the counters then as the pieces must be in rank order
    var ranks[12] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12];

    component pieceInRangeValidator[40];
    // component pieceInRangeValidatorP2[40];
    for (var i = 0; i < 40; i++) {
        // Check that each player has their pieces only on the four rows opposite of the original player
        pieceInRangeValidator[i] = PieceInSetupRange();
        pieceInRangeValidator[i].x <== playerPieces[i][0];
        pieceInRangeValidator[i].y <== playerPieces[i][1];
        pieceInRangeValidator[i].isPlayerOne <== 0;

        // Check that the pieces included are of the correct rank and in order
        if (i < 6) {
            ranks[0] === playerPieces[i][2];
        } else if (i == 6) {
            ranks[1] === playerPieces[i][2];
        } else if (i == 7) {
            ranks[2] === playerPieces[i][2];
        } else if (i > 7 && i <= 9) {
            ranks[3] === playerPieces[i][2];
        } else if (i >= 10 && i <= 12) {
            ranks[4] === playerPieces[i][2];
        } else if (i >= 13 && i <= 16) {
            ranks[5] === playerPieces[i][2];
        } else if (i >= 17 && i <= 20) {
            ranks[6] === playerPieces[i][2];
        } else if (i >= 21 && i <= 24) {
            ranks[7] === playerPieces[i][2];
        } else if (i >= 25 && i <= 29) {
            ranks[8] === playerPieces[i][2];
        } else if (i >= 30 && i <= 37) {
            ranks[9] === playerPieces[i][2];
        } else if (i == 38) {
            ranks[10] === playerPieces[i][2];
        } else if (i == 39) {
            ranks[11] === playerPieces[i][2];
        }
    }

    // TODO:
    // Can either form a bitmap of the board, or check a piece's coordinates against all other cooridnates
    // Should test whether one is more computationally expensive than the other
    component collisionChecker[1560]; // 39th triangular number is 780, and need to make two checks for x and y
    var k = 0;
    for (var i = 0; i < 40; i++) {
        for (var j = i+1; j < 40; j++) {
            // TODO: might be better to move this to another template that more cleanly compares x and y coordinates
            collisionChecker[k] = IsEqual();
            collisionChecker[k].in[0] <== playerPieces[i][0];
            collisionChecker[k].in[1] <== playerPieces[j][0];

            collisionChecker[k + 1] = IsEqual();
            collisionChecker[k + 1].in[0] <== playerPieces[i][1];
            collisionChecker[k + 1].in[1] <== playerPieces[j][1];

            // One of these out signals must be 0
            collisionChecker[k].out * collisionChecker[k+1].out === 0;
            k += 2;
        }
    }

    component hasher = MiMCSponge(121, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var pieceIndex = i \ 3;
        hasher.ins[i+1] <== playerPieces[pieceIndex][i % 3];
    }

    solnHashOut <== hasher.outs[0];
}

component main = JoinGame();