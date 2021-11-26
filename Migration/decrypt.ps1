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

# Compute the key and the initialization vector
# from the passphrase and the salt
# in old deprecated OpenSSL fashion
$params = Get-OpenSslMd5KeyAndIv -password $password -salt $salt;
$key = $params.Key;
$keyPretty = [System.BitConverter]::ToString($key);
Write-Host "Key: ", $keyPretty;

$iv = $params.Iv;
$ivPretty = [System.BitConverter]::ToString($iv);
Write-Host "IV: ", $ivPretty;
