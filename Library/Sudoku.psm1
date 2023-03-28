# returns a list of 27 "blocks" which must contain all 9 numbers
# each block is a list of 9 "points"
# each point is a coordinate pair pointing to a particular spot in the grid
#
# the 27 blocks are, in particular:
# * the 9 rows
# * the 9 columns
# * the 9 squares of 3x3
Function Get-SudokuBlocks {
	$blocks = [int[][][]]@(0 .. 26);
	$b = 0;

	# each row is a block
	@(0 .. 8) | ForEach-Object {
		$r = $_;

		$block = [int[][]]@(0 .. 8);
		$i = 0;

		@(0 .. 8) | ForEach-Object {
			$c = $_;

			$point = [int[]]@($r, $c);
			$block[$i] = $point;
			$i++;
		}

		$blocks[$b] = $block;
		$b++;
	}

	# each column is a block
	@(0 .. 8) | ForEach-Object {
		$c = $_;

		$block = [int[][]]@(0 .. 8);
		$i = 0;

		@(0 .. 8) | ForEach-Object {
			$r = $_;
			$point = [int[]]@($r, $c);
			$block[$i] = $point;
			$i++;
		}

		$blocks[$b] = $block;
		$b++;
	}

	# each square is a block
	@(0, 3, 6) | ForEach-Object {
		$sr = $_;

		@(0, 3, 6) | ForEach-Object {
			$sc = $_;

			$block = [int[][]]@(0 .. 8);
			$i = 0;
			@(0, 1, 2) | ForEach-Object {
				$rd = $_;

				@(0, 1, 2) | ForEach-Object {
					$cd = $_;
					$point = [int[]]@(($sr + $rd), ($sc + $cd));
					$block[$i] = $point;
					$i++;
				}
			}

			$blocks[$b] = $block;
			$b++;
		}
	}

	Return $blocks;
}
Export-ModuleMember -Function "Get-SudokuBlocks";

# given a string representation of a Sudoku grid,
# returns a multidimensional array representation
Function Get-SudokuGrid {
	Param([Parameter(Mandatory)][string]$position);

	$lines = $position -split "`r?`n";

	If ($lines.Count -ne 9) {
		Throw "Expected 9 rows, not " + $lines.Count;
	}

	$grid = @(1 .. 9);
	
	For ($i = 0; $i -lt 9; $i++) {
		$row = $lines[$i];

		If (-not ($row -Match "^[0-9]{9}$")) {
			Throw "malformed row $row";
		}

		$grid[$i] = $row.ToCharArray();
	}

	Return $grid;
}
Export-ModuleMember -Function "Get-SudokuGrid";

# given a multidimensional array representation of a Sudoku grid,
# prints it to the screen
Function Show-SudokuGrid {
	Param([Parameter(Mandatory)][char[][]]$grid);

	For ($i = 0; $i -lt 9; $i++) {
		# write the separator if necessary
		If (($i -gt 0) -and (($i % 3) -eq 0)) {
			Write-Host "---+---+---";
		}

		$r = $grid[$i];
		Write-Host(
			(
				($r[0 .. 2] -join ""), "|" +
				($r[3 .. 5] -join ""), "|",
				($r[6 .. 8] -join "")
			) -join "");
	}
}
Export-ModuleMember -Function "Show-SudokuGrid";

# solve a given Sudoku position
Function Find-SudokuSolution {
	Param(
		[Parameter(Mandatory)][char[][]]$grid,
		[Parameter(Mandatory)][int[][][]]$blocks
	);

	While (-not (Test-SudokuSolved -grid $grid)) {
		Switch (Test-SudokuSolutionStep -grid $grid -blocks $blocks) {
			$True {
				# so far so good, keep going
			}

			$False {
				# this position isn't solvable
				Return $False;
			}

			$Null {
				# ran out of easy steps
				# brute force the rest with guess-and-check
				Return Test-SudokuGridGuesses -grid $grid -block $blocks;
			}
		}
	}

	Return $True;
}
Export-ModuleMember -Function "Find-SudokuSolution";

# check whether the given position is solved
Function Test-SudokuSolved {
	Param([Parameter(Mandatory)][char[][]]$grid);

	For ($r = 0; $r -lt 9; $r++) {
		For ($c = 0; $c -lt 9; $c++) {
			If ($grid[$r][$c] -eq '0') {
				Return $False;
			}
		}
	}

	Return $True;
}

# check whether the given block contains the given cell
Function Test-SudokuBlockContainsCell {
	Param(
		[Parameter(Mandatory)][int[][]]$block,
		[Parameter(Mandatory)][int[]]$cell
	);

	For ($i = 0; $i -lt 9; $i++) {
		$cell2 = $block[$i];

		If (($cell[0] -eq $cell2[0]) -and ($cell[1] -eq $cell2[1])) {
			Return $True;
		}
	}

	Return $False;
}

# check whether the given block contains the given number in the given grid
Function Test-SudokuBlockContainsNumber {
	Param(
		[Parameter(Mandatory)][char[][]]$grid,
		[Parameter(Mandatory)][int[][]]$block,
		[Parameter(Mandatory)][char]$number
	);

	For ($i = 0; $i -lt 9; $i++) {
		$cell = $block[$i];

		If ($grid[$cell[0]][$cell[1]] -eq $n) {
			Return $True;
		}
	}

	Return $False;
}

# try to find the next step in the solution
# True - we found the next step
# False - no solution is possible
# Null - it might be solvable but we couldn't find the next step
Function Test-SudokuSolutionStep {
	Param(
		[Parameter(Mandatory)][char[][]]$grid,
		[Parameter(Mandatory)][int[][][]]$blocks
	);

	# look for blocks that have eight elements filled
	For ($b = 0; $b -lt 27; $b++) {
		$cells = $blocks[$b];
		$remaining = @{};
		@([char]'1' .. [char]'9') | ForEach-Object {
			$remaining[$_] = 1;
		}

		$lastr = 0;
		$lastc = 0;
		
		For ($i = 0; $i -lt 9; $i++) {
			$cell = $cells[$i];

			$r = $cell[0];
			$c = $cell[1];
			$n = $grid[$r][$c];

			If ($n -eq '0') {
				$lastr = $r;
				$lastc = $c;
			} ElseIf ($remaining.ContainsKey($n)) {
				$remaining.Remove($n);
			} Else {
				Write-Host "Multiple $n in the same block";
				Return $False;
			}
		}

		# we found one!
		# fill in the ninth cell
		If ($remaining.Count -eq 1) {
			$n = $remaining.Keys | ForEach-Object { Return $_; }
			Write-Host "($lastr, $lastc) is the last empty square in a block, it must be $n";
			$grid[$lastr][$lastc] = $n;
			Return $True;
		}
	}

	# iterate over cells that are zero
	# look for ones that have exactly one possibility left
	# when excluding those that are used in intersecting blocks
	For ($r = 0; $r -lt 9; $r++) {
		For ($c = 0; $c -lt 9; $c++) {
			$cell = @($r, $c);

			If ($grid[$r][$c] -ne '0') {
				Continue;
			}

			# there are initially nine possibilities for the empty cell
			$possible = @{};
			@([char]'1' .. [char]'9') | ForEach-Object {
				$possible[$_] = 1;
			}

			# but the cell is part of three blocks
			# remove any possibility that is already used in any of these blocks
			For ($b = 0; $b -lt 27; $b++) {
				$block = $blocks[$b];

				If (Test-SudokuBlockContainsCell -block $block -cell $cell) {
					$numbers_in_block = @{};

					$block_relevant = $False;

					For ($i = 0; $i -lt 9; $i++) {
						$cell2 = $block[$i];

						$n = $grid[$cell2[0]][$cell2[1]];
						If ($n -ne '0') {
							$numbers_in_block[$n] = 1;
						}
					}

					$numbers_in_block.Keys | ForEach-Object {
						$n = $_;

						If ($possible.ContainsKey($n)) {
							$possible.Remove($n);
						}
					}
				}
			}

			Switch ($possible.Count) {
				0 {
					Write-Host "All values for ($r, $c) already used in intersecting blocks";
					Return $False;
				}

				1 {
					$possible.Keys | ForEach-Object { $n = $_; }
					Write-Host "All values for ($r, $c) except for $n already used in intersecting blocks";
					$grid[$r][$c] = $n;
					Return $True;
				}
			}
		}
	}

	# look for numbers that have only one place left to be
	$digits = "123456789".ToCharArray();
	ForEach ($n In $digits) {
		# look at each block NOT containing the number
		For ($b = 0; $b -lt 27; $b++) {
			$block = $blocks[$b];

			If (Test-SudokuBlockContainsNumber -grid $grid -block $block -number $n) {
				Continue;
			}

			# check each empty cell in the block
			$possible_cells = 0;
			$lastr = 0;
			$lastc = 0;

			For ($i = 0; $i -lt 9; $i++) {
				$cell = $block[$i];
				$r = $cell[0];
				$c = $cell[1];

				If ($grid[$r][$c] -eq '0') {
					# look at other blocks containing this cell
					# see if any of them contain this number
					# if so, this cell is not possible
					$possible = $True;

					For ($b2 = 0; $b2 -lt 27; $b2++) {
						$block2 = $blocks[$b2];

						If (-not (Test-SudokuBlockContainsCell -block $block2 -cell $cell)) {
							Continue;
						}

						If (Test-SudokuBlockContainsNumber -grid $grid -block $block2 -number $n) {
							$colliding_block = $b2;
							$possible = $False;
							Break;
						}
					}

					If ($possible) {
						$possible_cells++;
						$lastr = $r;
						$lastc = $c;
					}
				}
			}

			Switch ($possible_cells) {
				0 {
					Write-Host "$n does not fit anywhere in block #$b";
					Return $False;
				}
				1 {
					Write-Host "$n's position in block #$b can only be ($lastr, $lastc)";
					$grid[$lastr][$lastc] = $n;
					Return $True;
				}
			}
		}
	}

	Write-Host "Not immediately clear what the next step is";
	Return $Null;
}

Function Copy-SudokuGrid {
	Param(
		[Parameter(Mandatory)][char[][]]$from,
		[Parameter(Mandatory)][char[][]]$to
	)

	For ($r = 0; $r -lt 9; $r++) {
		For ($c = 0; $c -lt 9; $c++) {
			$to[$r][$c] = $from[$r][$c];
		}
	}
}

# given a Sudoku grid and the set of blocks,
# find the block with the fewest blank squares (2, 3, or 4)
# make 2! = 2 or 3! = 6 or 4! = 24 copies of the grid
# fill that block a different way in each copy
# then attempt to solve all the copies
# if all goes well, precisely one copy will have a solution
Function Test-SudokuGridGuesses {
	Param(
		[Parameter(Mandatory)][char[][]]$grid,
		[Parameter(Mandatory)][int[][][]]$blocks
	)

	$minimum_blanks = 10;
	$numbers = [char[]]@();
	$cells = [int[][]]@();
	For ($b = 0; $b -lt 27; $b++) {
		$block = $blocks[$b];

		$blank_cells  = [int[][]]@();
		$remain = @{};
		@([char]'1' .. [char]'9') | ForEach-Object { $remain[$_] = 1; }

		For ($i = 0; $i -lt 9; $i++) {
			$cell = $block[$i];

			$n = $grid[$cell[0]][$cell[1]];

			If ($n -eq '0') {
				$blank_cells += ,$cell;
				Continue;
			}

			If (-not $remain.ContainsKey($n)) {
				Throw "Block $b contains $n twice";
			}

			$remain.Remove($n);
		}

		If (($remain.Count -gt 0) -and $remain.Count -lt $minimum_blanks) {
			$minimum_blanks = $remain.Count;
			$cells = $blank_cells;
			$numbers = $remain.Keys | Sort-Object;
		}
	}

	$cells_pretty = $cells | ForEach-Object {
		Return "(" + $_[0] + ", " + $_[1] + ")";
	}

	Write-Host "GUESSING on block #$b which has $minimum_blanks blank cells";

	If (($numbers.Count -lt 2) -or ($numbers.Count -gt 4)) {
		Throw "No guessing unless there are 2, 3, or 4 empy slots, not " + $numbers.Count;
	}

	Switch ($numbers.Count) {
		2 { $patterns = @("ab", "ba"); }
		3 { $patterns = @("abc", "acb", "bac", "bca", "cab", "cba"); }
		4 { $patterns = @(
				"abcd", "abdc", "acbd", "acdb", "adbc", "adcb",
				"bacd", "badc", "bcad", "bcda", "bdac", "bdca",
				"cabd", "cadb", "cbad", "cbda", "cdab", "cdba",
				"dabc", "dacb", "dbac", "dbca", "dcab", "dcba"
		) }
	}

	$total_solved = 0;
	$last_solved = [char[][]]@();

	ForEach ($pattern In $patterns) {
		$pattern = $pattern.Replace("a", $numbers[0]);
		$pattern = $pattern.Replace("b", $numbers[1]);
		If ($numbers.Count -ge 2) {
			$pattern = $pattern.Replace("c", $numbers[2]);
		}
		If ($numbers.Count -ge 3) {
			$pattern = $pattern.Replace("d", $numbers[3]);
		}

		Write-Host "Trying", $pattern;
		$ns = $pattern.ToCharArray();
		$new = [char[][]]::new(9, 9);
		Copy-SudokuGrid -from $grid -to $new;

		For ($i = 0; $i -lt $cells.Count; $i++) {
			$cell = $cells[$i];
			$new[$cell[0]][$cell[1]] = $ns[$i];
		}

		If (Find-SudokuSolution -grid $new -blocks $blocks) {
			$total_solved++;
			$last_solved = $new;
		}
	}

	If ($total_solved -gt 1) {
		Throw "Solution is not unique";
	}

	If ($total_solved -eq 0) {
		Write-Host "No solutions";
		Return $False;
	}

	Copy-SudokuGrid -from $last_solved -to $grid;
	Return $True;
}
