@echo off
setlocal

set started=%date% %time%
echo Started at %started%

call perl.exe -I%~dp0Library -w %*

echo Started at %started%, ended at %date% %time%