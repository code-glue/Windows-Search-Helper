@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set FileExtensionsPath=%~dp0BinaryFileExtensions.txt
set RegisterBinaryFileExtension=%~dp0RegisterNullFilterForFileExt.bat
set Arg1=%1

REM echo.DEBUG ExitCode='%ExitCode%'
REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG FileExtensionsPath='%FileExtensionsPath%'
REM echo.DEBUG RegisterBinaryFileExtension='%RegisterBinaryFileExtension%'
REM echo.DEBUG Arg1='%Arg1%'

if defined Arg1 goto HelpArg

goto RegisterFileExtensions


:RegisterFileExtensions
REM echo.DEBUG :RegisterFileExtensions %*
set ExitCode=0

call :CheckAdmin
if %ErrorLevel% equ 0 (set "IsAdmin=1") else (set "IsAdmin=0")
REM echo.DEBUG :IsAdmin=%IsAdmin%


echo.
echo.Registering Windows Search null filters for the following file extensions:
echo.
for /f "usebackq eol=' tokens=*" %%a in ("%FileExtensionsPath%") do (
    <nul set /p =.%%a 
    call "%RegisterBinaryFileExtension%" "%%a" >nul
    if !ErrorLevel! neq 0 (
        set ExitCode=1
        if !IsAdmin! equ 0 goto ExitPause
    )
)
echo.
echo.

goto ExitPause


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
echo.
echo.Description:
echo.  Configures Windows Search to ignore the contents of all files which have any
echo.  of the below file extensions (generally binary files). If the file extension
echo.  is already registered with a different filter, it will be saved so that it
echo.  may be later restored.
echo.
echo.File extensions:
for /f "usebackq eol=' tokens=*" %%a in ("%FileExtensionsPath%") do (
    set AllExts=!AllExts!.%%a 
)

echo.  %AllExts%
echo.
echo.Usage:
echo.  %ThisFileNameNoExt% ^<No Parameters^>
echo.

goto Exit


:CheckAdmin
net session >nul 2>&1
exit /b %ErrorLevel%


:ExitPause
REM Pause if this script was not run from a command line.
set CmdCmdLineNoQuotes=!CmdCmdLine:"=!
set CmdCmdLineNoFileName=!CmdCmdLineNoQuotes:%ThisFileName%=!
if "!CmdCmdLineNoQuotes!" == "!CmdCmdLineNoFileName!" goto Exit
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
