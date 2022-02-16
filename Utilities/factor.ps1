Param([int]$n);

$originalN = $n;

$factorsTable = @{};

For ([int]$p = 2; $n -gt 1; $p++) {
    While (($n % $p) -eq 0) {
        $n /= $p;
        $factorsTable[$p] += 1;
    }
}

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

Write-Host $originalN, "=", $factorsList;
