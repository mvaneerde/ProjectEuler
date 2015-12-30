@echo off
setlocal

set visual_cplusplus=%programfiles(x86)%\Microsoft Visual Studio 14.0\VC
set kit_inc=%programfiles(x86)%\Windows Kits\10\Include\10.0.10586.0
set kit_lib=%programfiles(x86)%\Windows Kits\10\Lib\10.0.10586.0

set INCLUDE=%visual_cplusplus%\include
set INCLUDE=%INCLUDE%;%kit_inc%\um
set INCLUDE=%INCLUDE%;%kit_inc%\ucrt
set INCLUDE=%INCLUDE%;%~dp0..\Library

set LIB=%visual_cplusplus%\lib
set LIB=%LIB%;%kit_lib%\um\x86
set LIB=%LIB%;%kit_lib%\ucrt\x86

call "%visual_cplusplus%\bin\cl.exe" ^
	/nologo ^
	/TP ^
	%*