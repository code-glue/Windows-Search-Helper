@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0

goto StartService


:StartService
set SearchServicePid=0
call :GetSearchServicePid
REM echo.DEBUG SearchServicePid=%SearchServicePid%

if %SearchServicePid% neq 0 goto ServiceAlreadyStarted

REM Start the Windows Search service.
call :SetErrorLevel 0
net start wsearch 2>nul

REM If starting the service failed, force kill its process and retry.
if %ErrorLevel% neq 0 (
    echo>&2.Failed to start the Windows Search service.
    REM echo>&2.Attemping to force kill its process ...
    REM call :ForceKillSearchService || (echo>&2.The Windows Search service could not be stopped. & goto Exit)
    REM echo Retrying ...
    REM verify >nul
    REM net start wsearch
    goto ExitPause
)

set ExitCode=0
goto ExitPause


:GetSearchServicePid
call :SetErrorLevel 0
for /f "tokens=3" %%a in ('sc queryex wsearch ^| findstr PID') do (set "SearchServicePid=%%a")
exit /b %ErrorLevel%


REM :ForceKillProcess
REM call :SetErrorLevel 0
REM taskkill /pid %SearchServicePid% /f
REM exit /b %ErrorLevel%


:ServiceAlreadyStarted
echo.Windows Search service is already running.
set ExitCode=0
goto ExitPause


:SetErrorLevel
REM echo.DEBUG :SetErrorLevel %*
exit /b %1


:CheckAdmin
net session >nul 2>&1
exit /b %ErrorLevel%


:ExitPause
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
if %ExitCode% neq 0 (
    call :CheckAdmin    
    if %ErrorLevel% neq 0 echo>&2.Try running this script as Administrator.
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
