// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./interfaces/IBoardSetupVerifier.sol";
import "./interfaces/IVerifier.sol";
import "./interfaces/IGame.sol";

contract Game is IGame {
    uint256 public gameIndex;

    // TODO: create winner functionality for the gameplay in order to complete it

    mapping(uint256 => Game) public games;

    IBoardSetupVerifier boardSetupVerifier;
    IJoinGameVerifier joinGameVerifier;
    IMoveVerifier moveVerifier;
    IAttackVerifier attackVerifier;

    constructor(
        address _boardSetupVerifier, 
        address _joinGameVerifier,
        address _moveVerifier,
        address _attackVerifier
    ) {
        boardSetupVerifier = IBoardSetupVerifier(_boardSetupVerifier);
        joinGameVerifier = IJoinGameVerifier(_joinGameVerifier);
        moveVerifier = IMoveVerifier(_moveVerifier);
        attackVerifier = IAttackVerifier(_attackVerifier);
    }

    function gameState(uint256 _gameId)
        external
        view
        returns (
            address[2] memory _participants,
            uint256[2] memory _boards,
            uint256 _nonce,
            uint256[2] memory _hits,
            address _winner
        )
    {
        Game storage game = games[_gameId];

        _participants = game.participants;
        _boards = game.boards;
        _nonce = game.nonce;
        _hits = game.hits;
        _winner = game.winner;
    }

    function ranksMatrixToArray(uint256[40][2] memory pieces) internal returns (uint256[80] memory) {
        uint256[80] memory pieceMatrixAsArray = [pieces[0][0], pieces[0][1], pieces[1][0], pieces[1][1], pieces[2][0], pieces[2][1], pieces[3][0], pieces[3][1],
pieces[4][0], pieces[4][1], pieces[5][0], pieces[5][1], pieces[6][0], pieces[6][1], pieces[7][0], pieces[7][1], 
pieces[8][0], pieces[8][1], pieces[9][0], pieces[9][1], pieces[10][0], pieces[10][1], pieces[11][0], pieces[11][1], 
pieces[12][0], pieces[12][1], pieces[13][0], pieces[13][1], pieces[14][0], pieces[14][1], pieces[15][0], pieces[15][1], 
pieces[16][0], pieces[16][1], pieces[17][0], pieces[17][1], pieces[18][0], pieces[18][1], pieces[19][0], pieces[19][1], 
pieces[20][0], pieces[20][1], pieces[21][0], pieces[21][1], pieces[22][0], pieces[22][1], pieces[23][0], pieces[23][1], 
pieces[24][0], pieces[24][1], pieces[25][0], pieces[25][1], pieces[26][0], pieces[26][1], pieces[27][0], pieces[27][1], 
pieces[28][0], pieces[28][1], pieces[29][0], pieces[29][1], pieces[30][0], pieces[30][1], pieces[31][0], pieces[31][1], 
pieces[32][0], pieces[32][1], pieces[33][0], pieces[33][1], pieces[34][0], pieces[34][1], pieces[35][0], pieces[35][1], 
pieces[36][0], pieces[36][1], pieces[37][0], pieces[37][1], pieces[38][0], pieces[38][1], pieces[39][0], pieces[39][1]];
        return pieceMatrixAsArray;
    }

    function startGame(
        uint256 _boardHash,
        uint256[40][2] memory piecesNoRanks,
        bytes memory proof
    ) external {
        // TODO: move these to using the ranksMatrixToArrayFunction
        require(boardSetupVerifier.verifyProof(
            proof, 
            [_boardHash, piecesNoRanks[0][0], piecesNoRanks[0][1], piecesNoRanks[1][0], piecesNoRanks[1][1], piecesNoRanks[2][0], piecesNoRanks[2][1], piecesNoRanks[3][0], piecesNoRanks[3][1],
piecesNoRanks[4][0], piecesNoRanks[4][1], piecesNoRanks[5][0], piecesNoRanks[5][1], piecesNoRanks[6][0], piecesNoRanks[6][1], piecesNoRanks[7][0], piecesNoRanks[7][1], 
piecesNoRanks[8][0], piecesNoRanks[8][1], piecesNoRanks[9][0], piecesNoRanks[9][1], piecesNoRanks[10][0], piecesNoRanks[10][1], piecesNoRanks[11][0], piecesNoRanks[11][1], 
piecesNoRanks[12][0], piecesNoRanks[12][1], piecesNoRanks[13][0], piecesNoRanks[13][1], piecesNoRanks[14][0], piecesNoRanks[14][1], piecesNoRanks[15][0], piecesNoRanks[15][1], 
piecesNoRanks[16][0], piecesNoRanks[16][1], piecesNoRanks[17][0], piecesNoRanks[17][1], piecesNoRanks[18][0], piecesNoRanks[18][1], piecesNoRanks[19][0], piecesNoRanks[19][1], 
piecesNoRanks[20][0], piecesNoRanks[20][1], piecesNoRanks[21][0], piecesNoRanks[21][1], piecesNoRanks[22][0], piecesNoRanks[22][1], piecesNoRanks[23][0], piecesNoRanks[23][1], 
piecesNoRanks[24][0], piecesNoRanks[24][1], piecesNoRanks[25][0], piecesNoRanks[25][1], piecesNoRanks[26][0], piecesNoRanks[26][1], piecesNoRanks[27][0], piecesNoRanks[27][1], 
piecesNoRanks[28][0], piecesNoRanks[28][1], piecesNoRanks[29][0], piecesNoRanks[29][1], piecesNoRanks[30][0], piecesNoRanks[30][1], piecesNoRanks[31][0], piecesNoRanks[31][1], 
piecesNoRanks[32][0], piecesNoRanks[32][1], piecesNoRanks[33][0], piecesNoRanks[33][1], piecesNoRanks[34][0], piecesNoRanks[34][1], piecesNoRanks[35][0], piecesNoRanks[35][1], 
piecesNoRanks[36][0], piecesNoRanks[36][1], piecesNoRanks[37][0], piecesNoRanks[37][1], piecesNoRanks[38][0], piecesNoRanks[38][1], piecesNoRanks[39][0], piecesNoRanks[39][1]]), 
            "Invalid pieces configuration for player one!");

        games[gameIndex].participants[0] = msg.sender;
        games[gameIndex].boards[0] = _boardHash;
        games[gameIndex].piecesNoRanksPlayerOne[0] = piecesNoRanks;

        emit Started(gameIndex, msg.sender);

        gameIndex++;
    }

    function joinGame(
        uint256 _gameId,
        uint256 _boardHash,
        uint256[40][2] memory piecesNoRanks,
        bytes memory proof
    ) external {
        Game storage game = games[_gameId];

        require(game.participants[1] == address(0), "Game already full!");
        require(joinGameVerifier.verifyProof(
            proof, 
            [_boardHash, piecesNoRanks[0][0], piecesNoRanks[0][1], piecesNoRanks[1][0], piecesNoRanks[1][1], piecesNoRanks[2][0], piecesNoRanks[2][1], piecesNoRanks[3][0], piecesNoRanks[3][1],
piecesNoRanks[4][0], piecesNoRanks[4][1], piecesNoRanks[5][0], piecesNoRanks[5][1], piecesNoRanks[6][0], piecesNoRanks[6][1], piecesNoRanks[7][0], piecesNoRanks[7][1], 
piecesNoRanks[8][0], piecesNoRanks[8][1], piecesNoRanks[9][0], piecesNoRanks[9][1], piecesNoRanks[10][0], piecesNoRanks[10][1], piecesNoRanks[11][0], piecesNoRanks[11][1], 
piecesNoRanks[12][0], piecesNoRanks[12][1], piecesNoRanks[13][0], piecesNoRanks[13][1], piecesNoRanks[14][0], piecesNoRanks[14][1], piecesNoRanks[15][0], piecesNoRanks[15][1], 
piecesNoRanks[16][0], piecesNoRanks[16][1], piecesNoRanks[17][0], piecesNoRanks[17][1], piecesNoRanks[18][0], piecesNoRanks[18][1], piecesNoRanks[19][0], piecesNoRanks[19][1], 
piecesNoRanks[20][0], piecesNoRanks[20][1], piecesNoRanks[21][0], piecesNoRanks[21][1], piecesNoRanks[22][0], piecesNoRanks[22][1], piecesNoRanks[23][0], piecesNoRanks[23][1], 
piecesNoRanks[24][0], piecesNoRanks[24][1], piecesNoRanks[25][0], piecesNoRanks[25][1], piecesNoRanks[26][0], piecesNoRanks[26][1], piecesNoRanks[27][0], piecesNoRanks[27][1], 
piecesNoRanks[28][0], piecesNoRanks[28][1], piecesNoRanks[29][0], piecesNoRanks[29][1], piecesNoRanks[30][0], piecesNoRanks[30][1], piecesNoRanks[31][0], piecesNoRanks[31][1], 
piecesNoRanks[32][0], piecesNoRanks[32][1], piecesNoRanks[33][0], piecesNoRanks[33][1], piecesNoRanks[34][0], piecesNoRanks[34][1], piecesNoRanks[35][0], piecesNoRanks[35][1], 
piecesNoRanks[36][0], piecesNoRanks[36][1], piecesNoRanks[37][0], piecesNoRanks[37][1], piecesNoRanks[38][0], piecesNoRanks[38][1], piecesNoRanks[39][0], piecesNoRanks[39][1]]), 
            "Invalid pieces configuration for player one!");

        game.participants[1] = msg.sender;
        game.boards[1] = _boardHash;
        games[gameIndex].piecesNoRanksPlayerTwo[0] = piecesNoRanks;

        emit Joined(_gameId, msg.sender);
    }
    
    // The first turn will always be a move as a piece can only move up one and will not be able to hit 
    function playFirstTurn(
        uint256 _gameId, 
        uint256 _boardHash,
        uint256[3] memory _pieceToMove,
        uint256[3] memory _newPieceLocation,
        bytes memory proof
    ) external {
        Game storage game = games[_gameId];

        require(game.nonce == 0, "Not the first turn!");
        require(msg.sender == game.participants[0], "Not turn!");
        playMove(_gameId, _boardHash, _pieceToMove, _newPieceLocation, proof);
    }

    // TODO: maybe can get rid of this in place of one `turn` method that works for all cases
    // TODO: moves require a change in the game board done by the player themselves, better to do this now rather than later
    // Moves will require the player to submit a new board hash and piece configuration
    // Only an attack requires the opponent to compute the attack proof before submititng a move/attack themselves
    function playMove(
        uint256 _gameId, 
        uint256 _boardHash,
        uint256[3] memory _pieceToMove,
        uint256[3] memory _newPieceLocation,
        bytes memory proof
    ) internal {
        Game storage game = games[_gameId];

        // require(game.nonce == 0, "Not the first turn!");
        // require(msg.sender == game.participants[0], "Not turn!");
        uint256[40][2] memory pieces = game.nonce % 2 == 0 ? game.piecesNoRanksPlayerOne[game.nonce] : game.piecesNoRanksPlayerTwo[game.nonce];
        uint256[80] memory piecesArray = ranksMatrixToArray(pieces);
        uint256[85] memory proofInputs;
        proofInputs[0] = _boardHash;
        for (uint i=1; i < piecesArray.length; i++) {
            proofInputs[i] = piecesArray[i];
        }
        proofInputs[81] = _pieceToMove[0]; proofInputs[82] = _pieceToMove[1]; proofInputs[83] = _newPieceLocation[0]; proofInputs[84] = _newPieceLocation[1];
        require(
            moveVerifier.verifyProof(
                proof,
                proofInputs
            ),
            "Invalid move proof"
        );
        // TODO: perhaps we do not need to change board hash at all, just used configurations stored in the contract for all comparisons after initial game creation
        game.boards[game.nonce % 2] = _boardHash;
        game.moves[game.nonce] = _pieceToMove;

        uint256[40][2] storage previousPieces = game.piecesNoRanksPlayerOne[game.nonce];
        uint indexToChange = 0;
        for (uint i = 0; i < 40; i++) {  //for loop example
            if (previousPieces[i][0] == _pieceToMove[0] && previousPieces[i][1] == _pieceToMove[1]) {
                indexToChange = i;
                break;
            }       
        }
        previousPieces[indexToChange][0] = _newPieceLocation[0];
        previousPieces[indexToChange][1] = _newPieceLocation[1];

        game.piecesNoRanksPlayerOne[game.nonce] = previousPieces;

        emit PieceMoved(_gameId, _pieceToMove, _newPieceLocation);

        game.nonce++;
    }

    function playTurn(
        uint256 _gameId,
        uint256[3] memory _nextPieceToMove,
        uint256[3] memory _newPieceLocation,
        uint256 _boardHash, // board hash changes upon a successful move or attack,
        uint256 _result, // result for an attack move performed last by the opponent
        uint256[3] memory _defendingPiece, // defending piece with ranking if attacked by opponent in previous round
        bytes memory proof,
        uint256 _lostAttackBoardHash,
        bytes memory _lostAttackProof
    ) external {
        Game storage game = games[_gameId];
        require(game.nonce != 0, "Turn=0");

        // Piece from previous round that is to be removed in an attack
        uint256[3] memory lostPiece = (game.nonce - 1) % 2 == 0 ? game.playerTwoLostPiece[game.nonce - 1] : game.playerOneLostPiece[game.nonce - 1];
        if (lostPiece[2] == 1) { // 
            playMove(_gameId, _lostAttackBoardHash, [lostPiece[0], lostPiece[1], 0], [uint256(11), 11, 0], _lostAttackProof);
        }

        uint256 currentBoardHash = game.boards[game.nonce % 2];
        uint256[3] memory move = game.moves[game.nonce - 1];
        if (move[2] != 0) {
            uint256[3] memory attack = game.attacks[game.nonce - 1];
            // uint256[3] memory defense = game.defenses[game.nonce - 1];
            // Person being attacked proving that they processed an attack correctly
            // TODO: add logic that the known piece orientation matches the hidden board hash
            require(attackVerifier.verifyProof(
                    proof,
                    [_result, _boardHash, currentBoardHash, move[0], move[1], move[2], _defendingPiece[0], _defendingPiece[1], _defendingPiece[2]] // TODO: add defending piece here. we reveal the defending piece rankings upon being attacked
                ),
                "Invalid attack proof"
            );
            // Loss
            if (_result == 0) {
                uint256[40][2] storage previousPieces = (game.nonce % 2 == 0) ? game.piecesNoRanksPlayerOne[game.nonce]: game.piecesNoRanksPlayerTwo[game.nonce];
                uint256[40][2] storage opponentPieces = (game.nonce % 2 == 1) ? game.piecesNoRanksPlayerOne[game.nonce]: game.piecesNoRanksPlayerTwo[game.nonce];
                uint indexToChange = 0;
                uint opponentPieceIndex = 0;
                for (uint i = 0; i < 40; i++) {  //for loop example
                    if (previousPieces[i][0] == _defendingPiece[0] && previousPieces[i][1] == _defendingPiece[1]) {
                        indexToChange = i;
                    }       
                    if (opponentPieces[i][0] == move[0] && opponentPieces[i][1] == move[1]) {
                        opponentPieceIndex = i;
                    }
                }
                previousPieces[indexToChange][0] = 0; previousPieces[indexToChange][1] = 0; previousPieces[indexToChange][2] = 0;
                opponentPieces[opponentPieceIndex][0] = _defendingPiece[0]; opponentPieces[opponentPieceIndex][1] = _defendingPiece[1];

                game.nonce % 2 == 0 ? game.piecesNoRanksPlayerOne[game.nonce] = previousPieces: game.piecesNoRanksPlayerTwo[game.nonce] = previousPieces;
                game.nonce % 2 == 1 ? game.piecesNoRanksPlayerOne[game.nonce] = opponentPieces: game.piecesNoRanksPlayerTwo[game.nonce] = opponentPieces;

                // Check if flag has been captured
                if (_defendingPiece[2] == 2) {
                    game.winner = game.participants[(game.nonce - 1) % 2];
                }    
            } else if (_result == 1) { // Win
                game.nonce % 2 == 0 ? game.playerTwoLostPiece[game.nonce] = [move[0], move[1], 1]: game.playerOneLostPiece[game.nonce] = [move[0], move[1], 1];
            }
            game.moves[game.nonce] = _nextPieceToMove;

            emit PieceMoved(_gameId, _nextPieceToMove, _newPieceLocation);
            game.nonce++; 
        } 
        // In the case that the move is an attack it should be performed by the player calling the move rather than the opponent
        // No private inputs are needed for a move and can be done on the same move
        if (move[2] == 0) {
            playMove(_gameId, _boardHash, _nextPieceToMove, _newPieceLocation, proof);
        }
    }

}