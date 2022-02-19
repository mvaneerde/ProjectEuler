Param([Parameter(Mandatory)][int]$n);

Import-Module "..\Library\Euler.psm1";

$s = Get-IntegerSquareRoot -n $n;
Write-Host "The integer square root of $n is $s";
