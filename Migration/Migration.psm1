Function Get-OpenSslMd5KeyAndIv {
    Param(
        [string]$password,
        [byte[]]$salt
    )

    # Early versions of OpenSSL use this way
    # to derive an AES key and initialization vector
    # from a given password and salt
    #
    # It is insecure because it allows for quite quick password recovery

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

Function Get-Password {
    $password = Get-Content "..\.password";
    Return $password;
}
Export-ModuleMember -Function "Get-Password";

Function Get-ProtectedPath {
    Param(
        [string]$filename
    )

    $encryptedFilename = ($filename -replace "\.decrypted\.([^\.]+)`$", ".`$1.encrypted");

    If ($filename -eq $encryptedFilename) {
        Throw "$filename does not match the spec for a decrypted file";
    }

    Return $encryptedFilename;
}
Export-ModuleMember -Function "Get-ProtectedPath";

Function Get-Rfc2898Pbkdf2KeyAndIv {
    Param(
        [string]$password,
        [byte[]]$salt,
        [int]$iterations,
        [string]$hash
    )

    # RFC 2898 specifies more secure password-based key derivation functions
    # This uses PBKDF2
    $pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $password,
        $salt,
        $iterations,
        $hash);

    $params = @{
        Key = $pbkdf2.GetBytes(32); # 256 bits
        Iv = $pbkdf2.GetBytes(16); # 128 bits
    };

    return $params;
}
Export-ModuleMember -Function "Get-Rfc2898Pbkdf2KeyAndIv";

Function Get-UnprotectedPath {
    Param(
        [string]$filename
    )

    $decryptedFilename = ($filename -replace "\.([^\.]+)\.encrypted`$", ".decrypted.`$1");

    If ($filename -eq $decryptedFilename) {
        Throw "$filename does not match the spec for an encrypted file";
    }

    Return $decryptedFilename;
}
Export-ModuleMember -Function "Get-UnprotectedPath";

Function Protect-File {
    Param(
        [string]$filename
    )

    $outputFilename = Get-ProtectedPath -filename $filename;

    $outputBytes = [System.Text.Encoding]::UTF8.GetBytes("Salted__");

    # generate a random eight-byte salt
    $salt = [System.BitConverter]::GetBytes([int64]0);
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($salt);

    $outputBytes += $salt;

    $password = Get-Password;

    $params = Get-Rfc2898Pbkdf2KeyAndIv `
        -password $password `
        -salt $salt `
        -iterations 10000 `
        -hash "SHA256";
    $key = $params.Key;
    $iv = $params.Iv;

    $aes = [System.Security.Cryptography.Aes]::Create();
    $aes.Key = $key;
    $aes.IV = $iv;

    $encryptor = $aes.CreateEncryptor($aes.Key, $aes.IV);
    $encryptedMemory = [System.Io.MemoryStream]::new();
    $cryptoStream = [System.Security.Cryptography.CryptoStream]::new(
        $encryptedMemory,
        $encryptor,
        [System.Security.Cryptography.CryptoStreamMode]::Write);

    $encryptedStream = [System.Io.StreamWriter]::new($cryptoStream);
    $plaintext = Get-Content -Path $filename -Raw;
    $encryptedStream.Write($plaintext);

    $encryptedStream.Dispose();
    $cryptoStream.Dispose();
    $encryptedBytes = $encryptedMemory.ToArray();
    $outputBytes += $encryptedBytes;

    [System.Convert]::ToBase64String(
        $outputBytes,
        [System.Base64FormattingOptions]::InsertLineBreaks
    ) | Out-File $outputFilename;
}
Export-ModuleMember -Function "Protect-File";

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

Function Unprotect-File {
    Param(
        [string]$filename
    )

    $outputFilename = Get-UnprotectedPath -filename $filename;

    $base64 = Get-Content $filename;
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

    # Compute the key and the initialization vector
    # from the passphrase and the salt
    # in old deprecated OpenSSL fashion
    $password = Get-Password;
    $params = Get-Rfc2898Pbkdf2KeyAndIv `
        -password $password `
        -salt $salt `
        -iterations 10000 `
        -hash "SHA256";
    $key = $params.Key;
    $iv = $params.Iv;

    $aes = [System.Security.Cryptography.Aes]::Create();
    $aes.Key = $key;
    $aes.IV = $iv;

    $decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV);

    $encryptedBytes = $bytes[16 .. ($bytes.Length - 1)];
    $encryptedStream = [System.Io.MemoryStream]::new($encryptedBytes);

    $cryptoStream = [System.Security.Cryptography.CryptoStream]::new(
        $encryptedStream,
        $decryptor,
        [System.Security.Cryptography.CryptoStreamMode]::Read);

    $decryptedStream = [System.Io.StreamReader]::new($cryptoStream);
    $decryptedText = $decryptedStream.ReadToEnd();
    $decryptedText | Out-File $outputFilename;
}
Export-ModuleMember -Function "Unprotect-File";
