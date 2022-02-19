Param([Parameter(Mandatory)][int]$n);

Import-Module "..\Library\Euler.psm1";

$f = Get-Factorial -n $n;
Write-Host "${n}! = ${f}";
