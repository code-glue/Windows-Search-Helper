@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set Arg1=%1

REM echo.DEBUG ExitCode='%ExitCode%'
REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG Arg1='%Arg1%'

if not defined Arg1 goto NoArgs

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'

if not defined Arg1NoQuotes call :BadArg & goto ExitPause

set Arg2=%2
set Arg1NoSpaces=%Arg1NoQuotes: =%
set Extension=.%Arg1NoQuotes%

REM echo.DEBUG Arg2='%Arg2%'
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
REM echo.DEBUG Extension='%Extension%'

if "!Arg1NoSpaces!" == "/?" goto HelpArg
if defined Arg2 goto TooManyArgs

goto GetExtension


:NoArgs
REM echo.DEBUG :NoArgs %*
call :PrintHeader


:UserEnterExtension
REM Prompt the user for the file extension. On error, reset and try again.
REM echo.DEBUG :UserEnterExtension %*
call :SetErrorLevel 0
set /p Arg1="Enter file extension [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg1=" & goto UserEnterExtension

REM echo.DEBUG Arg1='%Arg1%'
if not defined Arg1 goto UserEnterExtension

set Arg1NoSpaces=%Arg1: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if not defined Arg1NoSpaces goto UserEnterExtension

call :Trim Arg1Trimmed %Arg1%
REM echo.DEBUG Arg1Trimmed='%Arg1Trimmed%'

set Arg1NoQuotes=%Arg1Trimmed:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if not defined Arg1NoQuotes call :BadArg & goto ExitPause

set Extension=.%Arg1NoQuotes%
REM echo.DEBUG Extension='%Extension%'

goto GetExtension


:GetExtension
REM echo.DEBUG :GetExtension %*
REM echo.DEBUG Extension='%Extension%'

for /f "tokens=*" %%a in ("!Extension!") do (
    set "Extension=%%~xa"
)

REM echo.DEBUG Extension='%Extension%'

if not defined Extension call :BadArg & goto ExitPause
if "!Extension!" == "." call :BadArg & goto ExitPause

goto BeginRegistration


:BeginRegistration
REM echo.DEBUG :BeginRegistration %*

set RegKeyHKLM=HKLM\Software\Classes\%Extension%\PersistentHandler
set DefaultPersistentHandler={00000000-0000-0000-0000-000000000000}
set OriginalPersistentHandlerExists=0
set CurrentPersistentHandler=
set AlreadyRegistered=0

REM echo.DEBUG RegKeyHKLM='%RegKeyHKLM%'

REM Check if the registry key exists and create it if necessary; exit on failure.
call :SetErrorLevel 0
reg query "%RegKeyHKLM%" /ve >nul 2>&1
if %ErrorLevel% neq 0 (
    echo.DEBUG Registry key does not exist: "!RegKeyHKLM!"
    call :SetErrorLevel 0
    reg add "!RegKeyHKLM!" /ve /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKeyHKLM!" & goto ExitPause
    goto SetPersistentHandler
)

REM Get the current PersistentHandler.
for /f "tokens=2*" %%a in ('reg query "!RegKeyHKLM!" /ve 2^>nul') do set "CurrentPersistentHandler=%%b"
echo.DEBUG CurrentPersistentHandler='%CurrentPersistentHandler%'

REM If the current PersistentHandler is empty, just delete the default value and exit.
REM echo.DEBUG CurrentPersistentHandler='%CurrentPersistentHandler%'
if not defined CurrentPersistentHandler goto SetPersistentHandler

call :SetErrorLevel 0
if /i "!CurrentPersistentHandler!" == "(value not set)" (
    reg add "!RegKeyHKLM!" /ve /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKeyHKLM!" & goto ExitPause
    set "CurrentPersistentHandler=!DefaultPersistentHandler!"
)

REM echo.DEBUG CurrentPersistentHandler='%CurrentPersistentHandler%'
if /i "!CurrentPersistentHandler!" == "!DefaultPersistentHandler!" set "AlreadyRegistered=1"
REM echo.DEBUG AlreadyRegistered=%AlreadyRegistered%

REM Check if the "OriginalPersistentHandler" value exists.
reg query "%RegKeyHKLM%" /v "OriginalPersistentHandler" >nul 2>&1
if %ErrorLevel% equ 0 set "OriginalPersistentHandlerExists=1"
REM echo.DEBUG OriginalPersistentHandlerExists='%OriginalPersistentHandlerExists%'


:SetPersistentHandler
REM Set the new PersistentHandler.
call :SetErrorLevel 0
reg delete "!RegKeyHKLM!" /ve /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: "!RegKeyHKLM!" & goto ExitPause
set ExitCode=0

REM Display message and exit if there is already a properties-only filter.
if %AlreadyRegistered% neq 0 (
    echo.Windows Search properties-only filter already registered for file extension: !Extension!
    goto ExitPause
)

echo.Registered Windows Search properties-only filter for file extension: !Extension!

REM Save the old PersistentHandler if necessary.
if not defined CurrentPersistentHandler goto ExitPause
if %OriginalPersistentHandlerExists% neq 0 goto ExitPause

reg add "%RegKeyHKLM%" /v "OriginalPersistentHandler" /d "!CurrentPersistentHandler!" /f >nul
if %ErrorLevel% neq 0 (
    set ExitCode=1
    echo>&2.Failed to save original filter: "!CurrentPersistentHandler!"
    echo>&2.Registry key: "!RegKeyHKLM!"
)

goto ExitPause


:Trim
REM Trims leading and trailing whitespace.
SetLocal EnableDelayedExpansion
REM echo.DEBUG :Trim %*
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b


:SetErrorLevel
REM echo.DEBUG :SetErrorLevel %*
exit /b %1


:TooManyArgs
REM echo.DEBUG :TooManyArgs %*
echo>&2.Too many arguments.
goto :Usage


:BadArg
REM echo.DEBUG :BadArg %*
echo>&2.Invalid extension: "%Arg1NoQuotes%"
exit /b 1


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
call :PrintHeader
echo.Usage:
echo.  %ThisFileNameNoExt% [.]Extension
echo.
echo.    Extension    Name of the extension to register, optionally prefixed by "."
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the file extension.
echo.
echo.  C:\^>%ThisFileNameNoExt% "sln"
echo.    Registers a Windows Search properties-only filter for .sln files.
echo.
echo.  C:\^>%ThisFileNameNoExt% .sln
echo.    Registers a Windows Search properties-only filter for .sln files.

goto Exit


:PrintHeader
echo.
echo.Description:
echo.  Configures Windows Search to index only the file properties (and not the
echo.  contents) of files with the specified extension. If the file extension is
echo.  already registered with a different filter, it will be saved so that it may
echo.  be later restored.
echo.
exit /b 1


:CheckAdmin
net session >nul 2>&1
exit /b %ErrorLevel%


:ExitPause
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
if %ExitCode% neq 0 (
    call :CheckAdmin    
    if !ErrorLevel! neq 0 echo>&2.Try running this script as Administrator.
)
REM Pause if this script was not run from a command line.
set CmdCmdLineNoQuotes=!CmdCmdLine:"=!
set CmdCmdLineNoFileName=!CmdCmdLineNoQuotes:%ThisFileName%=!
if "!CmdCmdLineNoQuotes!" == "!CmdCmdLineNoFileName!" goto Exit
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
