// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGame {
    event Started(uint256 _gameId, address _by);
    event Joined(uint256 _gameId, address _by);
    event PieceMoved(uint256 _gameId, uint256[3] _pieceToMove, uint256[3] _newLocation);
    event PieceAttacked(uint256 _gameId, uint256[3] _attackingPiece, uint256[3] _defendingPiece);
    event Won(uint256 _gameId, address _by);

    struct Game {
        /// The address of the two players.
        address[2] participants;
        /// The hash committing to the ranks configuration of each player
        uint256[2] boards;
        /// The turn number of this game.
        uint256 nonce;
        
        /// Mapping of player shot indices to turn number.
        /// The shot indices of the second player are offset by 100.
        // mapping(uint256 => uint256) shots;

        /// Mapping of game nonce to moves, attacks, defenses
        mapping(uint256 => uint256[3]) moves;
        mapping(uint256 => uint256[3]) attacks;
        mapping(uint256 => uint256[3]) defenses;

        /// Mapping of game nonce to the current board configuration without ranking for each piece
        // TODO: consider changing to a simple array so that we can easily switch between them with game.nonce
        mapping(uint256 => uint256[40][2]) piecesNoRanksPlayerOne;
        mapping(uint256 => uint256[40][2]) piecesNoRanksPlayerTwo;
        /// Mapping of game nonce to piece in the case of a lost attack
        mapping(uint256 => uint256[2]) playerOneLostPiece;
        mapping(uint256 => uint256[2]) playerTwoLostPiece;
        /// The number of pieces each player has taken from their opponent
        uint256[2] hits;
        /// The winner of the game.
        address winner;
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
        );

    function startGame(
        uint256 _boardHash,
        uint256[40][2] memory piecesNoRanks,
        bytes memory proof
    ) external;

    // function joinGame(
    //     uint256 _gameId,
    //     uint256 _boardHash, // The hash of the locations of the pieces with their rankings (private)
    //     uint256 _piecesHash, // The hash of the locations of the pieces without their rankings (public)
    //     bytes memory proof
    // ) external;

    function joinGame(
        uint256 _gameId,
        uint256 _boardHash,
        uint256[40][2] memory piecesNoRanks,
        bytes memory proof
    ) external;

    // function playFirstTurn(uint256 _gameId, uint256[3] memory _pieceToMove) external;

    // The first turn will always be a move as a piece can only move up one and will not be able to hit 
    function playFirstTurn(
        uint256 _gameId, 
        uint256 _boardHash,
        uint256[3] memory _pieceToMove,
        uint256[3] memory _newPieceLocation,
        bytes memory proof
    ) external;
    
    // function playMove(
    //     uint256 _gameId,
    //     uint256[3] memory _pieceToMove,
    //     uint256[2] memory a,
    //     uint256[2][2] memory b,
    //     uint256[2] memory c
    // ) external;

    // TODO: may need entirely separate circuits for a win, loss vs a tie
    // a tie resulting in both board hashing changing while a win or loss is either the attacking or defending board hash changing
    // We will have the the last index of `_nextPieceToMove` specify whether the last move that is being processed is an attack or normal move
    // 
    function playTurn(
        uint256 _gameId,
        uint256[3] memory _nextPieceToMove,
        uint256[3] memory _newPieceLocation,
        uint256 _boardHash, // board hash changes upon a successful move or attack,
        uint256 _result, // result for an attack move performed last by the opponent
        uint256[3] memory _defendingPiece, // defending piece with ranking if attacked by opponent in previous round
        bytes memory proof    
    ) external;

}