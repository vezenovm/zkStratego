# zkStratego

Stratego is a popular game that requires planning, deception, and a good memory to defeat the opponent by finding their flag. The game is based on a player not knowing their opponent’s field setup, which heavily lends itself to utilizing ZK for its implementation. To give a clearer picture of the game a summarized description has been provided below.

Two players compete against one another with a set of 40 pieces, of which the pieces have varying abilities. The game board in Stratego begins with each player being blind to the placement of the opposing player’s pieces. When the game starts there are two moves which are possible, an attack or a move. A move simply moves a piece to an open adjacent space, while an attack is an attempt to move onto an opponent’s occupied space. 
Whether an attack is successful is determined by the ranking of the given piece. On an attack the attacking player will reveal their piece’s rank. The opponent then declares their piece's rank and the lower of the two is removed from the board. If the attacking piece wins it moves onto the defending piece’s space. If the defending piece wins it remains where it was originally. If the pieces are the same rank, both are removed from the board. The distribution of the piece ranks and their distribution among the entire piece set can be found here: https://www.hasbro.com/common/instruct/Stratego.PDF.

There is a flag piece that cannot be moved and upon capture the game is concluded. The game can also be won if on a player’s turn all of their moveable pieces have been removed, thus requiring them to forfeit to their opponent. There are also some additional rules that can be added to make the game more challenging, but this overview is what I am looking to implement.

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```


