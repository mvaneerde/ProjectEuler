@echo off
setlocal

set visual_cplusplus=%programfiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.27.29110
set kit_inc=%programfiles(x86)%\Windows Kits\10\Include\10.0.18362.0
set kit_lib=%programfiles(x86)%\Windows Kits\10\Lib\10.0.18362.0

set INCLUDE=%visual_cplusplus%\include
set INCLUDE=%INCLUDE%;%kit_inc%\um
set INCLUDE=%INCLUDE%;%kit_inc%\ucrt
set INCLUDE=%INCLUDE%;%~dp0Library

set LIB=%visual_cplusplus%\lib\x86
set LIB=%LIB%;%kit_lib%\um\x86
set LIB=%LIB%;%kit_lib%\ucrt\x86

rem /TP means treat the files being compiled as C++
rem rather than inferring the type from the extension
rem
rem /EHsc allows using things like std::vector
if /i "%processor_architecture%"=="amd64" (
	set cl_arch=x64
) else (
	set cl_arch=x86
)
call "%visual_cplusplus%\bin\Host%cl_arch%\%cl_arch%\cl.exe" ^
	/EHsc ^
	/nologo ^
	/TP ^
	%*
