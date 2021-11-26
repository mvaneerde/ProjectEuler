Param([Parameter(Mandatory)]$key);

Function Test-ArraysEqual {
    Param([byte[]]$a, [byte[]]$b);

    If ($a.Length -ne $b.Length) {
        Return $False;
    }

    For ($i = 0; $i -lt $a.Length; $i++) {
        If ($a[$i] -ne $b[$i]) {
            Return $False;
        }
    }

    Return $True;
}

$base64 = Get-Content "test-file.txt.encrypted";
$bytes = [System.Convert]::FromBase64String($base64);

If ($bytes.Length -lt 16) {
    Throw "Not enough bytes for a header";
}

$magic = [System.Text.Encoding]::UTF8.GetBytes("Salted__");

$first = $bytes[0..7];
If (!(Test-ArraysEqual $first $magic)) {
    Throw "This is not an OpenSSL encrypted byte stream";
}

$salt = $bytes[8..15];
$saltPretty = [System.BitConverter]::ToString($salt);
Write-Host "Salt: ", $saltPretty;
