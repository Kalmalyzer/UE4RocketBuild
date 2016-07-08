@echo off
setlocal
pushd %~dp0

IF "%1"=="" (

ECHO this adds an Unreal engine association between an identifier that you specify on the commandline, and the current folder.
ECHO
ECHO typical usage: RegisterEngineVersion.cmd 4.10.0-HomeBuilt-4f37f2cd
PAUSE

) ELSE (

rem Install prerequisites...
echo Installing prerequisites...
start /wait Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe /quiet

rem Register the engine installation...
reg add "HKEY_CURRENT_USER\SOFTWARE\Epic Games\Unreal Engine\Builds" /f /v "%1" /t REG_SZ /d "%~dp0\"

)
