Import-Module ".\Migration.psm1";

$encryptedFiles = Get-ChildItem -Path "..\*.encrypted" -Recurse;
$encryptedFiles | ForEach-Object {
    $encryptedFile = $_.FullName;

    $decryptedFile = Get-UnprotectedPath -filename $encryptedFile;
    If (!(Test-Path -path $decryptedFile)) {
        Write-Host "Decrypting $encryptedFile to $decryptedFile";
        Unprotect-File -filename $encryptedFile;
    }
}
