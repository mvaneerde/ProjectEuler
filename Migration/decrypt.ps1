Param([Parameter(Mandatory)]$password);

Import-Module ".\Migration.psm1";

$base64 = Get-Content "test-file.txt.encrypted";
$bytes = [System.Convert]::FromBase64String($base64);

If ($bytes.Length -lt 16) {
    Throw "Not enough bytes for a header";
}

$magic = [System.Text.Encoding]::UTF8.GetBytes("Salted__");

$first = $bytes[0..7];
If (!(Test-ByteArraysEqual $first $magic)) {
    Throw "This is not an OpenSSL encrypted byte stream";
}

$salt = $bytes[8..15];
$saltPretty = [System.BitConverter]::ToString($salt);
Write-Host "Salt: ", $saltPretty;

$md5 = [System.Security.Cryptography.MD5CryptoServiceProvider]::new();
$passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($password);

$d1 = $md5.ComputeHash($passwordBytes + $salt);
$d2 = $md5.ComputeHash($d1 + $passwordBytes + $salt);
$d3 = $md5.ComputeHash($d2 + $passwordBytes + $salt);

$key = $d1 + $d2;
$keyPretty = [System.BitConverter]::ToString($key);
Write-Host "Key: ", $keyPretty;

$iv = $d3;
$ivPretty = [System.BitConverter]::ToString($iv);
Write-Host "IV: ", $ivPretty;

