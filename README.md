# cover3x3
openscad program for a cover-up tic-tac-toe game

![cover3x3 board, box, and pieces][thumbnail]

# pieces

* _board_ - 3x3 grid of squares, same as tic-tac-toe
* _cups_ - nesting pieces in 2 colors, each color having 2 each of 3 sizes. cups are played open side down, to cover smaller cups.
* _stack_ - a set of one or more nested cups

# rules

a game for 2 players

## start

the game starts with an empty board.

each player starts with 2 full stacks of the same color.

## play

players take turns placing cups of their color, either from one of their stacks onto the board, or by moving from one location on the board to another.

moving from one board location to another may uncover a cup, which is then in play.

cups can be placed on empty squares, or to cover a cup of a smaller size, of either color.

## finish

a player wins when there is a full row of their color, either horizontally, vertically, or diagonally.

winning may happen either as a result of a player's own move, or their opponent's.

if a position is repeted 3 times, the game ends in a draw.


# notes

* this openscad program depends on the [`slide_top_box` module][slide_top_box]
* Gobblet (4x4) and Gobblet Gobblers (3x3) are board games designed by Thierry Denoual and published by Blue Orange Games that introduced the cover mechanic.



[slide_top_box]: https://github.com/ellemenno/slide_top_box "openscad module for a sliding dovetail lidded box"
[thumbnail]: ./cover3x3.png "rendering of the game board and pieces"
