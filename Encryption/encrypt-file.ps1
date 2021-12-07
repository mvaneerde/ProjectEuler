Param([Parameter(Mandatory)]$filename);

Import-Module ".\Encryption.psm1";
Protect-File -filename $filename;
