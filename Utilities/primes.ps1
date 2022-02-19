Param([int]$max);

Import-Module "..\Library\Euler.psm1";

$primes = Get-Primes -max $max;
Write-Host "Primes <= ${max}:";
Write-Host $primes;
