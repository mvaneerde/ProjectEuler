Import-Module ".\Migration.psm1";

$decryptedFiles = Get-ChildItem -Path "..\*.decrypted.*" -Recurse;
$decryptedFiles | ForEach-Object {
    $decryptedFile = $_.FullName;

    $encryptedFile = Get-ProtectedPath -filename $decryptedFile;
    If (!(Test-Path -path $encryptedFile)) {
        Write-Host "Encrypting $decryptedFile to $encryptedFile";
        Protect-File -filename $decryptedFile;
    }
}
