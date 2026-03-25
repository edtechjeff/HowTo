@echo off
set LOGFILE=C:\Windows\Setup\Scripts\SetupComplete.log

echo ================================================== >> "%LOGFILE%"
echo SetupComplete started %date% %time% >> "%LOGFILE%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\Setup\Scripts\Apply-ComputerName.ps1" >> "%LOGFILE%" 2>&1

echo SetupComplete finished %date% %time% >> "%LOGFILE%"
exit /b 0