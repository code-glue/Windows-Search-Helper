@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set WinSearchRegKey=HKLM\Software\Microsoft\Windows Search
set WinSearchRegValue=DataDirectory
set IndexLocation=

goto DeleteAndRebuildIndex


:DeleteAndRebuildIndex
call :GetIndexLocation
REM echo.DEBUG IndexLocation='%IndexLocation%'
if %ErrorLevel% neq 0 goto ExitPause

call :GetSearchServicePid
REM echo.DEBUG SearchServicePid=%SearchServicePid%
if %ErrorLevel% neq 0 goto ExitPause

call :StopService
if %ErrorLevel% neq 0 goto ExitPause

call :DeleteIndex
if %ErrorLevel% neq 0 goto ExitPause

call :StartService
if %ErrorLevel% neq 0 goto ExitPause

set ExitCode=0
goto ExitPause


:GetIndexLocation
call :SetErrorLevel 0
reg query "!WinSearchRegKey!" /v "!WinSearchRegValue!" >nul
if %ErrorLevel% neq 0 echo>&2.Registry Key -- Value: "!WinSearchRegKey!" -- "!WinSearchRegValue!" & exit /b 1

for /f "tokens=2*" %%a in ('reg query "!WinSearchRegKey!" /v "!WinSearchRegValue!" 2^>nul') do set "IndexLocation=%%b"
if defined IndexLocation exit /b 0

echo>&2.Failed to get Windows Search index location from registry.
echo>&2.Registry Key -- Value: "!WinSearchRegKey!" -- "!WinSearchRegValue!"
exit /b 1


:GetSearchServicePid
call :SetErrorLevel 0
for /f "tokens=3" %%a in ('sc queryex wsearch ^| findstr PID') do (set "SearchServicePid=%%a")
if defined SearchServicePid exit /b 0

echo>&2.Failed to get process for Windows Search service (wsearch).
exit /b 1


:StopService
REM if not defined SearchServicePid call :ServiceNotStarted & exit /b 0
if %SearchServicePid% equ 0 call :ServiceNotStarted & exit /b 0

call :SetErrorLevel 0
net stop wsearch /y 2>nul

if %ErrorLevel% neq 0 (
    echo>&2.Failed to stop the Windows Search service.
    echo>&2.Attemping to force kill its process . . .
    call :ForceKillProcess || (echo>&2.The Windows Search service could not be stopped. & exit /b 1)
)
exit /b 0


:StartService
call :SetErrorLevel 0
net start wsearch 2>nul

if %ErrorLevel% neq 0 (
    echo>&2.Failed to start the Windows Search service.
    exit /b 1
)
exit /b 0


:DeleteIndex
REM echo.DEBUG :DeleteIndex %*
echo.Deleting directory: "%IndexLocation%" . . .
call :SetErrorLevel 0
rd /s /q "%IndexLocation%"

REM rd does not provide a reliable exit code, so check if the directory still exists.
if exist "%IndexLocation%" echo>&2.Failed to delete Windows Search index. & echo. & exit /b 1
echo.Successfully deleted Windows Search index.
echo.
exit /b 0


:ForceKillProcess
REM echo.DEBUG :ForceKillProcess %*
call :SetErrorLevel 0
taskkill /pid %SearchServicePid% /f
exit /b %ErrorLevel%


:ServiceNotStarted
REM echo.DEBUG :ServiceNotStarted %*
echo.Windows Search service is not running.
exit /b 0


:SetErrorLevel
REM echo.DEBUG :SetErrorLevel %*
exit /b %1


:CheckAdmin
REM echo.DEBUG :CheckAdmin %*
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
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
