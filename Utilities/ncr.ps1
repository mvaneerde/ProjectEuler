Param(
    [Parameter(Mandatory)][int]$n,
    [Parameter(Mandatory)][int]$r
);

Import-Module "..\Library\Euler.psm1";

$nCr = Get-NChooseR -n $n -r $r;
Write-Host "${n}C${r} = $nCr";
