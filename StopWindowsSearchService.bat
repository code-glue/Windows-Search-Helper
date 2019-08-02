@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0

goto StopService


:StopService
call :GetSearchServicePid
REM echo.DEBUG SearchServicePid=%SearchServicePid%

if not defined SearchServicePid goto ServiceNotStarted
if %SearchServicePid% equ 0 goto ServiceNotStarted

call :SetErrorLevel 0
net stop wsearch /y 2>nul

if %ErrorLevel% neq 0 (
    echo>&2.Failed to stop the Windows Search service.
    echo>&2.Attemping to force kill its process . . .
    call :ForceKillProcess || (echo>&2.The Windows Search service could not be stopped. & goto ExitPause)
)
set ExitCode=0
goto ExitPause


:GetSearchServicePid
call :SetErrorLevel 0
for /f "tokens=3" %%a in ('sc queryex wsearch ^| findstr PID') do (set "SearchServicePid=%%a")
exit /b %ErrorLevel%


:ForceKillProcess
call :SetErrorLevel 0
taskkill /pid %SearchServicePid% /f
exit /b %ErrorLevel%


:ServiceNotStarted
echo.Windows Search service is not running.
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
