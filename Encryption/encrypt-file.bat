@echo off
setlocal

set decrypted=%1

if "%decrypted%" == "" (
	echo Specify a file to encrypt
	goto END
)

if not "%2" == "" (
	echo Only one argument please
)

if not exist "%~dp0..\.password" (
	echo Could not find password file
	goto END
)

set key=
for /f "usebackq delims=" %%k in (`type %~dp0..\.password`) do (
	if not "%%k" == "" set key=%%k
)

if "%key%"=="" (
	echo Password file does not contain a key
	goto END
)

set encrypted=%decrypted:.decrypted=.encrypted%
if /i "%decrypted%" == "%encrypted%" (
	echo Filename must end in .decrypted
	goto END
)

echo Encrypting %decrypted%...
call perl.exe -w %~dp0encrypt.pl "%key%" < %decrypted% > %encrypted%

:END