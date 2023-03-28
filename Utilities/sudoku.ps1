Param([Parameter(Mandatory)][string]$position);

Import-Module "..\Library\Sudoku.psm1";

$blocks = Get-SudokuBlocks;
$grid = Get-SudokuGrid $position;
If (Find-SudokuSolution -grid $grid -blocks $blocks) {
    Write-Host "-- Unique solution -- "
    Show-SudokuGrid -grid $grid;
} Else {
    Write-Host "-- No solution --";
}
