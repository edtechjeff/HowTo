@echo off
REM ======================================================
REM SetupComplete.cmd - runs after Windows setup finishes
REM Runs in SYSTEM context before first logon
REM ======================================================

:: Log start
echo %DATE% %TIME% - SetupComplete starting >> C:\Windows\Temp\SetupComplete.log

REM === Install Google Chrome ===
start /wait msiexec /i "C:\Windows\Setup\Scripts\googlechromestandaloneenterprise64.msi" /qn /norestart

REM === Install Cisco AnyConnect ===
start /wait msiexec /i "C:\Windows\Setup\Scripts\cisco-secure-client-win-5.1.8.122-core-vpn-predeploy-k9.msi" /qn /norestart

REM === Install Microsoft 365 Apps for Enterprise (Offline Packager) ===
start /wait C:\Windows\Setup\Scripts\OfficeDeploy\setup.exe /configure C:\Windows\Setup\Scripts\OfficeDeploy\config-packager.xml

REM == Copy VPN Preference File

if exist "C:\Windows\Setup\Scripts\VPN.COM_V3.xml.xml" (
    xcopy "C:\Windows\Setup\Scripts\VPN.COM_V3.xml.xml" "C:\ProgramData\Cisco\Cisco Secure Client\VPN\Profile\" /Y /I
    echo %DATE% %TIME% - VPN Preference file copied >> C:\Windows\Temp\SetupComplete.log
) else (
    echo %DATE% %TIME% - VPN Preference file missing, skipped >> C:\Windows\Temp\SetupComplete.log
)

:: Log end
echo %DATE% %TIME% - SetupComplete finished >> C:\Windows\Temp\SetupComplete.log
exit /b 0