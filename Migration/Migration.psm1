Function Get-OpenSslMd5KeyAndIv {
    Param(
        [string]$password,
        [byte[]]$salt
    )


    $md5 = [System.Security.Cryptography.MD5CryptoServiceProvider]::new();
    $passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($password);

    $d1 = $md5.ComputeHash($passwordBytes + $salt);
    $d2 = $md5.ComputeHash($d1 + $passwordBytes + $salt);
    $d3 = $md5.ComputeHash($d2 + $passwordBytes + $salt);

    $params = @{
        Key = $d1 + $d2;
        Iv = $d3;
    };

    return $params;
}
Export-ModuleMember -Function "Get-OpenSslMd5KeyAndIv";

Function Test-ByteArraysEqual {
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
Export-ModuleMember -Function "Test-ByteArraysEqual";
