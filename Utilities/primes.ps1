Param([Parameter(Mandatory)][int]$max);

Import-Module "..\Library\Euler.psm1";

$sieve = Get-PrimeSieve -max $max;
For ($p = [int]2; $p -le $max; $p++) {
    If (!$sieve[$p]) {
        Write-Host $p;
    }
}
