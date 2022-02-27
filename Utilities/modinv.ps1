Param(
    [Parameter(Mandatory)][int64]$n,
    [Parameter(Mandatory)][int64]$modulus
);

Import-Module "..\Library\Euler.psm1";

$x = Get-ModInv -n $n -modulus $modulus;
Write-Host "${n}^-1 mod ${modulus} = ${x}";
