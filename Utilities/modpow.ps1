Param(
    [Parameter(Mandatory)][int64]$base,
    [Parameter(Mandatory)][int64]$power,
    [Parameter(Mandatory)][int64]$modulus
);

Import-Module "..\Library\Euler.psm1";

$x = Get-ModPow -base $base -power $power -modulus $modulus;
Write-Host "${base}^${power} mod ${modulus} = ${x}";
