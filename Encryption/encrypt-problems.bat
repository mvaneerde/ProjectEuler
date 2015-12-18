@echo off
setlocal

for /f "usebackq delims=" %%f in (`dir /s /b %~dp0..\problems\*.decrypted`) do (
	call :ENCRYPT %%f
)

goto END

:ENCRYPT

set decrypted=%1
set encrypted=%decrypted:.decrypted=.encrypted%
if exist "%encrypted%" (
	rem skipping things that are already encrypted
	goto END
)

call %~dp0encrypt-file.bat %decrypted%

:END