@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0

goto RestartService


:RestartService
call :GetSearchServicePid
REM echo.DEBUG SearchServicePid=%SearchServicePid%

call :StopService
if %ErrorLevel% neq 0 goto ExitPause

call :StartService
if %ErrorLevel% neq 0 goto ExitPause

set ExitCode=0
goto ExitPause


:StopService
if not defined SearchServicePid call :ServiceNotStarted & exit /b 0
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
exit /b 0


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
