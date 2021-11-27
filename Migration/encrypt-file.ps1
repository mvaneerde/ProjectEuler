Param([Parameter(Mandatory)]$filename);

Import-Module ".\Migration.psm1";
Protect-File -filename $filename;
