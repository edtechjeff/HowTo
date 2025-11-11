## This is basic file that you can add what ever block you want. I have also one completed file that does show you an example of what one complete looks like. 

@echo off
REM ======================================================
REM SetupComplete.cmd - runs after Windows setup finishes
REM Runs in SYSTEM context before first logon
REM ======================================================

:: Log start
echo %DATE% %TIME% - SetupComplete starting >> C:\Windows\Temp\SetupComplete.log

REM == Put anything after this block to run as an install

:: Log end
echo %DATE% %TIME% - SetupComplete finished >> C:\Windows\Temp\SetupComplete.log
exit /b 0