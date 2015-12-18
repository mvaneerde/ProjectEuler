@echo off
setlocal

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

for /f "usebackq delims=" %%f in (`dir /s /b %~dp0..\problems\*.encrypted`) do (
	call :DECRYPT %%f
)

goto END

:DECRYPT

set encrypted=%1
set decrypted=%encrypted:.encrypted=.decrypted%
if exist "%decrypted%" (
	rem skipping things that are already decrypted
	goto END
)

echo Decrypting %encrypted%...
call perl.exe -w %~dp0decrypt.pl "%key%" < %encrypted% > %decrypted%

:END