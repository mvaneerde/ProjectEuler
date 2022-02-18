Param([int]$n);

Import-Module "..\Library\Euler.psm1";

$factorsTable = Get-Factors -n $n;

$factorsList = @();

$factorsTable.GetEnumerator() |
Sort-Object -Property "Name" |
ForEach-Object {
    $factor = $_;
    $factorString = [string]($factor.Name);

    If ($factor.Value -ne "1") {
        $factorString += "^" + $factor.Value;
    }

    $factorsList += $factorString;
}

Write-Host $n, "=", $factorsList;
