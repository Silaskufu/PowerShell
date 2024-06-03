<#
.SYNOPSIS
    Script to play a simple command-line Tic-Tac-Toe game.

.DESCRIPTION
    This PowerShell script allows two players to play a game of Tic-Tac-Toe in the command line. The game
    board is displayed and players take turns choosing their moves until there is a winner or a tie. The
    script handles input validation, displays the game board after each move, and announces the result of the game.

.PARAMETER $board
    The 3x3 game board represented as a 2D array of strings.

.PARAMETER $playerOneSymbol
    The symbol for player one, default is 'X'.

.PARAMETER $playerTwoSymbol
    The symbol for player two, default is 'O'.

.PARAMETER $gameover
    A boolean flag to indicate if the game is over.

.PARAMETER $currentPlayer
    The symbol of the player who is currently taking their turn.

.FUNCTION Start-Game
    Initiates the game, handles the main game loop, checks for winners, and switches players.

.FUNCTION Show-Board
    Displays the current state of the game board.
    
.FUNCTION Switch-Tile
    Handles a player's move, updates the game board, and validates the move.

.FUNCTION Get-Winner
    Checks the game board for a winning combination.

.FUNCTION Switch-Player
    Switches the current player to the next player.

.EXAMPLE
    .\TicTacToe.ps1
    This command will start the Tic-Tac-Toe game, display the board, and prompt players to enter their moves.

.NOTES
    Ensure to enter valid row and column numbers (0-2) during your turn. The game will announce the winner
    or if the game ends in a tie.
#>


$board = @(
    ('','',''),
    ('','',''),
    ('','','')
)

[char]$playerOneSymbol = "X"
[char]$playerTwoSymbol = "O"
$gameover = $false
$currentPlayer = $playerOneSymbol

function Start-Game(){
    param(
        $board,
        [bool]$switchTileSuccess,
        $currentPlayer
    )
    # Show board at the start of the game
    Show-Board -board $board

    
    while(-not $gameover){
        # set Tile Success to false for initial play to be made
        $switchTileSuccess = $false
        
        while(-not $switchTileSuccess){
            
            $row = Read-Host "Player $currentPlayer, Choose a row (0-2)"
            $col = Read-Host "Player $currentPlayer, Choose a column (0-2)"
    
            # changes tile if not successfull this while loop will be repeated
            $switchTileSuccess = Switch-Tile -row $row -col $col -board $board -playerSymbol $currentPlayer
        }
        # shows the board after the turn made
        Show-Board -board $board
        # check if there was a winner
        $winner = Get-Winner -board $board
        if($null -ne $winner){
            $gameover = $true
            Write-Host "Congrats, you win $currentPlayer!!"
        }
        
        elseif (-not (($board[0] -contains '') -or ($board[1] -contains '') -or ($board[2] -contains ''))) {
            $gameOver = $true
            Write-Host "It's a tie!!"
        }   
        else{
            $currentPlayer = Switch-Player -currentPlayer $currentPlayer
        }
    }
}
function Show-Board(){
    param (
        $board
    )
    $filler = "+---+---+---+"
    write-Host $filler
    for($i=0; $i -lt 3; $i++){
        Write-Host ("| " + $board[$i][0] + " | " + $board[$i][1] + " | " + $board[$i][2] + " |")
        Write-Host $filler
    }
}
function Switch-Tile(){
    param(
        $row,
        $col,
        $board,
        $playerSymbol
    )
    if($board[$row][$col] -eq ''){
        $board[$row][$col] = $playerSymbol
        return $true
    }
    else{
        Write-Host "Invalid move or position already occupied. Try again."
        return $false
    }
}
function Get-Winner(){
    param(
        $board,
        $currentPlayer
    )
    # Check Rows
    for($i=0;$i -lt 3; $i++){
        if($board[$i][0] -ne '' -and $board[$i][0] -eq $board[$i][1] -and $board[$i][0] -eq $board[$i][2]){
            return $board[$i][0]
        }
    }
    # Columns
    for($j=0;$j -lt 3; $j++){
        if($board[0][$j] -ne '' -and $board[0][$j] -eq $board[1][$j] -and $board[0][$j] -eq $board[2][$j]){
            return $board[0][$j]
        }
    }
    # Check diagonals
    if($board[0][0] -ne '' -and $board[0][0] -eq $board[1][1] -and $board[0][0] -eq $board[2][2]){
        return $board[0][0]
    }
    if($board[0][2] -ne '' -and $board[0][2] -eq $board[1][1] -and $board[0][2] -eq $board[2][0]){
        return $board[0][2]
    }
}
function Switch-Player(){
    param(
        $currentPlayer
    )
    if($currentPlayer -eq $playerOneSymbol){
        return $playerTwoSymbol       
    }
    else {
        return $playerOneSymbol
    }
}
# Startet spiel mit dem Board und dem Startspieler
Start-Game -board $board -currentPlayer $playerOneSymbol