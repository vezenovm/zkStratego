pragma circom 2.0.4;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "./templates/PieceinRange.circom";

// Checks whether the placement of pieces on the board is valid. 
// The board is 10 x 10 with two players occupying four rows on both ends with two empty rows in the middle
template BoardSetup() {
    // TODO: perhaps change to create a component piece that has a variables determining the rank, whether a piece is a bomb, miner, or scout, etc.

    // The rows are a piece represented by its x and y coordinates, and then its rank
    // Every ranked piece is represented by its rank 1-10. Bombs have a rank of 11 and can only be defeated by miners. The Flag has a rank of 12.
    // All game logic is done with ranks, which is fine as all the special pieces (Bomb, Miner, Scout, Spy) have a unique rank not shared by other generic pieces
    // Upon removal of a piece it can be specified with a rank of 0
    // More information on the game rules can be found here: https://www.hasbro.com/common/instruct/Stratego.PDF
    signal input playerPiecesWithRank[40][3];
    signal input playerPiecesNoRank[40][2];
    // Piece (x, y) locations specified as singular indices
    // signal input playerPiecesNoRank[40];

    signal input trapdoor;

    signal output solnHashOut;

    // Use hardcoded ranks array, and a set way the pieces must be specified in the inputs
    // No need for the counters then as the pieces must be in rank order
    // TODO: consider counters as an alternate strategy so that ranks do not have to be in a set order 
    // var ranks[12] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12];
    var bombCounter; var marshalCounter; var generalCounter; var colonelCounter; var majorCounter; var captainCounter;
    var lieutenantCounter; var sergeantCounter; var minerCounter; var scoutCounter; var spyCounter;
    var flagCounter;

    component pieceInRangeValidatorP1[40];
    component rankCheckerMux[40];
    component bombCountValidator[40];
    component marshalCountValidator[40]; component generalCountValidator[40]; component colonelCountValidator[40]; component majorCountValidator[40]; component captainCountValidator[40];
    component lieutenantCountValidator[40]; component sergeantCountValidator[40]; component minerCountValidator[40]; component scoutCountValidator[40];
    component spyCountValidator[40]; component flagCountValidator[40];
    for (var i = 0; i < 40; i++) {
        // Check that each player has their pieces only on the closest four rows to their starting side
        pieceInRangeValidatorP1[i] = PieceInSetupRange();
        pieceInRangeValidatorP1[i].x <== playerPiecesWithRank[i][0];
        pieceInRangeValidatorP1[i].y <== playerPiecesWithRank[i][1];
        pieceInRangeValidatorP1[i].isPlayerOne <== 1;

        /// TODO: need to add a way to check that the correct number of each ranked piece has been specified in the private ranked variables
        /// TODO: check if there is a better way to do this, currently rushing development and this could be cleaner
        bombCountValidator[i] = IsEqual();
        bombCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        bombCountValidator[i].in[1] <== 11;
        if (bombCountValidator[i].out == 1) {
            bombCounter += 1;
        }
        marshalCountValidator[i] = IsEqual();
        marshalCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        marshalCountValidator[i].in[1] <== 10;
        if (marshalCountValidator[i].out == 1) {
            marshalCounter += 1;
        }
        generalCountValidator[i] = IsEqual();
        generalCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        generalCountValidator[i].in[1] <== 9;
        if (generalCountValidator[i].out == 1) {
            generalCounter += 1;
        }
        colonelCountValidator[i] = IsEqual();
        colonelCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        colonelCountValidator[i].in[1] <== 8;
        if (colonelCountValidator[i].out == 1) {
            colonelCounter += 1;
        }
        majorCountValidator[i] = IsEqual();
        majorCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        majorCountValidator[i].in[1] <== 7;
        if (majorCountValidator[i].out == 1) {
            majorCounter += 1;
        }
        captainCountValidator[i] = IsEqual();
        captainCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        captainCountValidator[i].in[1] <== 6;
        if (captainCountValidator[i].out == 1) {
            captainCounter += 1;
        }
        lieutenantCountValidator[i] = IsEqual();
        lieutenantCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        lieutenantCountValidator[i].in[1] <== 5;
        if (lieutenantCountValidator[i].out == 1) {
            lieutenantCounter += 1;
        }
        sergeantCountValidator[i] = IsEqual();
        sergeantCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        sergeantCountValidator[i].in[1] <== 4;
        if (sergeantCountValidator[i].out == 1) {
            sergeantCounter += 1;
        }
        minerCountValidator[i] = IsEqual();
        minerCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        minerCountValidator[i].in[1] <== 3;
        if (minerCountValidator[i].out == 1) {
            minerCounter += 1;
        }
        scoutCountValidator[i] = IsEqual();
        scoutCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        scoutCountValidator[i].in[1] <== 2;
        if (scoutCountValidator[i].out == 1) {
            scoutCounter += 1;
        }
        spyCountValidator[i] = IsEqual();
        spyCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        spyCountValidator[i].in[1] <== 1;
        if (spyCountValidator[i].out == 1) {
            spyCounter += 1;
        }
        flagCountValidator[i] = IsEqual();
        flagCountValidator[i].in[0] <== playerPiecesWithRank[i][2];
        flagCountValidator[i].in[1] <== 12;
        if (flagCountValidator[i].out == 1) {
            flagCounter += 1;
        }
    }
    // Create a template to test counters against these values
    // marshalCounter === 1;
    // generalCounter === 1;
    // colonelCounter === 2;
    // etc.

    // compoent rankValueValidator[440];
    // for (var i = 0; i < 440; i+=11) {
    //     var index = i \ 11;

    //     rankEqualityChecker[i]
    // }

    // Check that the public piece indices match up with the private rankings
    component pieceEqualityChecker[80];
    for (var i = 0; i < 80; i+=2) {
        var pieceIndex = i \ 2;

        pieceEqualityChecker[i] = IsEqual();
        pieceEqualityChecker[i].in[0] <== playerPiecesWithRank[pieceIndex][0];
        pieceEqualityChecker[i].in[1] <== playerPiecesNoRank[pieceIndex][0];

        pieceEqualityChecker[i + 1] = IsEqual();
        pieceEqualityChecker[i + 1].in[0] <== playerPiecesWithRank[pieceIndex][1];
        pieceEqualityChecker[i + 1].in[1] <== playerPiecesNoRank[pieceIndex][1];

        pieceEqualityChecker[i].out * pieceEqualityChecker[i+1].out === 1;
    }

    // Using indices for the piece specifications. Results in same number of constriants as keeping (x, y) in matrix form. Could be changed to clean up Solidity
    // signal pieceIndex[40][2];
    // for (var i = 0; i < 40; i++) {
    //     pieceIndex[i][1] <-- playerPiecesNoRank[i] \ 10;
    //     pieceIndex[i][0] <== playerPiecesNoRank[i] - pieceIndex[i][1] * 10;

    //     pieceIndex[i][1] * 10 + pieceIndex[i][0] === playerPiecesNoRank[i];
    // }

    // for (var i = 0; i < 80; i+=2) {
    //     pieceEqualityChecker[i] = IsEqual();
    //     pieceEqualityChecker[i].in[0] <== playerPiecesWithRank[i / 2][0];
    //     pieceEqualityChecker[i].in[1] <== pieceIndex[i / 2][0];

    //     pieceEqualityChecker[i + 1] = IsEqual();
    //     pieceEqualityChecker[i + 1].in[0] <== playerPiecesWithRank[i / 2][1];
    //     pieceEqualityChecker[i + 1].in[1] <== pieceIndex[i / 2][1];

    //     pieceEqualityChecker[i].out * pieceEqualityChecker[i+1].out === 1;
    // }

    // TODO: add in collision check for each player's pieces
    // Can either form a bitmap of the board, or check a piece's coordinates against all other cooridnates
    // Should test whether one is more computationally expensive than the other
    component collisionCheckerP1[1560]; // 39th triangular number is 780, and need to make two checks for x and y
    var k = 0;
    for (var i = 0; i < 40; i++) {
        for (var j = i+1; j < 40; j++) {
            // TODO: might be better to move this to another template that more cleanly compares x and y coordinates
            collisionCheckerP1[k] = IsEqual();
            collisionCheckerP1[k].in[0] <== playerPiecesWithRank[i][0];
            collisionCheckerP1[k].in[1] <== playerPiecesWithRank[j][0];

            collisionCheckerP1[k + 1] = IsEqual();
            collisionCheckerP1[k + 1].in[0] <== playerPiecesWithRank[i][1];
            collisionCheckerP1[k + 1].in[1] <== playerPiecesWithRank[j][1];

            // One of these out signals must be 0
            collisionCheckerP1[k].out * collisionCheckerP1[k+1].out === 0;
            k += 2;
        }
    }

    component hasher = MiMCSponge(121, 220, 1);
    hasher.k <== 0;
    hasher.ins[0] <== trapdoor;
    for (var i = 0; i < 120; i++) {
        var index = i \ 3;
        hasher.ins[i+1] <== playerPiecesWithRank[index][i % 3];
    }

    solnHashOut <== hasher.outs[0];
}

component main { public [playerPiecesNoRank] } = BoardSetup();