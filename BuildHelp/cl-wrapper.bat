@echo off
setlocal

set LIB=%programfiles(x86)%\Microsoft Visual Studio 14.0\VC\lib
set LIB=%LIB%;%programfiles(x86)%\Windows Kits\10\Lib\10.0.10240.0\um\x86
set LIB=%LIB%;%programfiles(x86)%\Windows Kits\10\Lib\10.0.10240.0\ucrt\x86

call "%programfiles(x86)%\Microsoft Visual Studio 14.0\VC\bin\cl.exe" ^
	/I"%programfiles(x86)%\Windows Kits\10\Include\10.0.10240.0\ucrt" ^
	/I"%programfiles(x86)%\Microsoft Visual Studio 14.0\VC\include" ^
	%*