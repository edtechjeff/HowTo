@echo off
:: ===================================================================
:: DISM Servicing Menu - Self Elevating Script
:: ===================================================================

:: Self-elevate if not running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: -------------------------------------------------------------------
:: Environment setup
:: -------------------------------------------------------------------
setlocal EnableDelayedExpansion
color 1F

:: Base directory = script folder
set "BASEDIR=%~dp0"

:: Define working folders (your layout)
set "IMAGES=%BASEDIR%images"
set "MOUNT=%BASEDIR%mount"
set "WINREMOUNT=%BASEDIR%WinREMount"
set "DRIVERS=%BASEDIR%drivers"
set "UPDATES=%BASEDIR%updates"
set "SCRIPTS=%BASEDIR%scripts"

:: Log
echo %DATE% %TIME% - Script started >> "%BASEDIR%Script.log"

:: -------------------------------------------------------------------
:: Main Menu
:: -------------------------------------------------------------------
:MainMenu
cls
echo =========================================================
echo              DISM Image Servicing Menu
echo =========================================================
echo.
echo 1. Mount Image
echo 2. Export + Service Image
echo 3. Finalize Image (Commit/Discard)
echo 4. Add Drivers
echo 5. Remove Packages
echo 6. Add Updates
echo 7. Exit
echo.
set /p choice=Enter your choice (1-7): 

if "%choice%"=="1" goto MountImage
if "%choice%"=="2" goto ExportImage
if "%choice%"=="3" goto UnmountMenu
if "%choice%"=="4" goto AddDrivers
if "%choice%"=="5" goto RemovePackages
if "%choice%"=="6" goto Updates
if "%choice%"=="7" goto END

echo Invalid choice, please choose 1–7.
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Helper: Select Windows Version + Release
:: -------------------------------------------------------------------
:SelectSourceWim
cls
echo =========================================================
echo   Select Windows Version
echo =========================================================
echo 1. Windows 10
echo 2. Windows 11
echo.
set /p winChoice=Enter choice (1-2): 

if "%winChoice%"=="1" (
    set "WINOS=Windows10"
) else if "%winChoice%"=="2" (
    set "WINOS=Windows11"
) else (
    echo Invalid choice
    pause
    goto SelectSourceWim
)

echo.
set /p release=Enter release (e.g., 22H2, 24H2): 

:: Build path to WIM file
set "WIMFILE=\images\source\%WINOS%\%release%\install.wim"

if not exist "%WIMFILE%" (
    echo ERROR: WIM file not found at %WIMFILE%
    pause
    goto MainMenu
)

echo Using WIM file: %WIMFILE%
goto :eof


:: -------------------------------------------------------------------
:: Mount Image
:: -------------------------------------------------------------------
:MountImage
cls
setlocal EnableDelayedExpansion
set i=0

for %%a in ("%IMAGES%\*.wim") do (
    set /A i+=1
    set "file[!i!]=%%~a"
)

if %i%==0 (
    echo No WIM files found in %IMAGES%
    pause
    goto MainMenu
)

echo Available WIM files:
for /L %%n in (1,1,%i%) do echo %%n. !file[%%n]!

set /p "choice=Enter number to mount: "
set "selectedFile=!file[%choice%]!"

if not defined selectedFile (
    echo Invalid choice.
    pause
    goto MainMenu
)

echo Mounting: %selectedFile%
dism /Mount-Image /ImageFile:"%selectedFile%" /index:1 /MountDir:"%MOUNT%"
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Export + Service Image
:: -------------------------------------------------------------------
:ExportImage
cls
setlocal EnableDelayedExpansion
color 1F

:: Ask user for OS + Release
call :SelectSourceWim

:: Temp file for DISM output
set "TMPFILE=%TEMP%\wiminfo.txt"

echo.
echo =========================================================
echo Listing available images in: %WIMFILE%
echo =========================================================
dism /Get-WimInfo /WimFile:"%WIMFILE%" > "%TMPFILE%"

set "index=" & set "name="
for /f "usebackq tokens=1,* delims=:" %%A in ("%TMPFILE%") do (
    set "key=%%A"
    set "val=%%B"
    set "key=!key:~0,-1!"
    set "val=!val:~1!"

    if /i "!key!"=="Index" set "index=!val!"
    if /i "!key!"=="Name" (
        set "name=!val!"
        echo Index !index!: !name!
    )
)

echo.
set /p index=Enter the Index number to export: 
set /p outfile=Enter name of new WIM file (e.g., install_pro.wim): 
echo %outfile% | findstr /i "\.wim$">nul || set "outfile=%outfile%.wim"

set "DESTWIM=%IMAGES%\%outfile%"

echo.
echo =========================================================
echo Exporting Index %index% to %DESTWIM%
echo =========================================================
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%index% /DestinationImageFile:"%DESTWIM%" /Compress:max /CheckIntegrity

if %errorlevel% neq 0 (
    echo ERROR: Export failed.
    pause
    goto MainMenu
)

echo Export completed.
pause

:: -------------------------------------------------------------------
:: Mount Exported WIM
:: -------------------------------------------------------------------
:MOUNTWIM
cls
echo =========================================================
echo Mounting Exported WIM
echo =========================================================
dism /Mount-Image /ImageFile:"%DESTWIM%" /index:1 /MountDir:"%MOUNT%"
attrib -h -a -s "%MOUNT%\Windows\System32\Recovery\winre.wim"
pause

:: -------------------------------------------------------------------
:: Mount WinRE
:: -------------------------------------------------------------------
cls
echo =========================================================
echo Mounting WinRE
echo =========================================================
dism /Mount-Wim /WimFile:"%MOUNT%\Windows\System32\Recovery\winre.wim" /index:1 /MountDir:"%WINREMOUNT%"
pause

:: -------------------------------------------------------------------
:: Apply Drivers
:: -------------------------------------------------------------------
cls
echo =========================================================
echo Applying Drivers
echo =========================================================
if exist "%DRIVERS%\WinPE" (
    dism /image:"%WINREMOUNT%" /Add-Driver /Driver:"%DRIVERS%\WinPE" /recurse /ForceUnsigned
)
if exist "%DRIVERS%\RSTAT" (
    dism /image:"%MOUNT%" /Add-Driver /Driver:"%DRIVERS%\RSTAT" /recurse /ForceUnsigned
)
if exist "%DRIVERS%\VirtIONetwork" (
    dism /image:"%WINREMOUNT%" /Add-Driver /Driver:"%DRIVERS%\VirtIONetwork" /recurse /ForceUnsigned
)
pause

:: -------------------------------------------------------------------
:: Create Panther Directory
:: -------------------------------------------------------------------
cls
echo =========================================================
echo Create Panther Directory
echo =========================================================
set "dirPath=%MOUNT%\Windows\Panther"
if not exist "%dirPath%" mkdir "%dirPath%"
pause

:: -------------------------------------------------------------------
:: Run RemovePackages.ps1
:: -------------------------------------------------------------------
cls
echo =========================================================
echo Removing Provisioned Appx Packages
echo =========================================================
if exist "%SCRIPTS%\RemovePackages.ps1" (
    start /wait powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%\RemovePackages.ps1"
) else (
    echo Script not found: %SCRIPTS%\RemovePackages.ps1
)
pause

:: -------------------------------------------------------------------
:: Cleanup + Unmount
:: -------------------------------------------------------------------
:FINISH
cls
echo =========================================================
echo Cleaning up and Unmounting
echo =========================================================
dism /image:"%WINREMOUNT%" /Cleanup-image /StartComponentCleanup
dism /unmount-image /mountdir:"%WINREMOUNT%" /commit
dism /unmount-image /mountdir:"%MOUNT%" /commit

goto MainMenu


:: -------------------------------------------------------------------
:: Finalize (Unmount Menu)
:: -------------------------------------------------------------------
:UnmountMenu
cls
echo 1. Commit Image
echo 2. Discard Image
set /p choice=Enter choice: 

if "%choice%"=="1" (
    dism /Unmount-Image /MountDir:"%MOUNT%" /commit
) else if "%choice%"=="2" (
    dism /Unmount-Image /MountDir:"%MOUNT%" /discard
) else (
    echo Invalid option.
)
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Add Drivers
:: -------------------------------------------------------------------
:AddDrivers
cls
setlocal EnableDelayedExpansion
set i=0
for /D %%a in ("%DRIVERS%\*") do (
    set /A i+=1
    set "folder[!i!]=%%~a"
)
if %i%==0 (
    echo No driver folders in %DRIVERS%
    pause
    goto MainMenu
)

echo Available driver folders:
for /L %%n in (1,1,%i%) do echo %%n. !folder[%%n]!

set /p choice=Select folder: 
set "selectedFolder=!folder[%choice%]!"

if not defined selectedFolder (
    echo Invalid choice
    pause
    goto MainMenu
)

echo Adding drivers from %selectedFolder%
dism /Image:"%MOUNT%" /Add-Driver /Driver:"%selectedFolder%" /recurse /ForceUnsigned
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Remove Packages (standalone)
:: -------------------------------------------------------------------
:RemovePackages
cls
if exist "%SCRIPTS%\RemovePackages.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%\RemovePackages.ps1"
) else (
    echo Script not found: %SCRIPTS%\RemovePackages.ps1
)
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Add Updates
:: -------------------------------------------------------------------
:Updates
cls
setlocal EnableDelayedExpansion
set i=0
for /D %%a in ("%UPDATES%\*") do (
    set /A i+=1
    set "folder[!i!]=%%~a"
)
if %i%==0 (
    echo No update folders in %UPDATES%
    pause
    goto MainMenu
)

echo Available update folders:
for /L %%n in (1,1,%i%) do echo %%n. !folder[%%n]!

set /p choice=Select folder: 
set "selectedFolder=!folder[%choice%]!"

if not defined selectedFolder (
    echo Invalid choice
    pause
    goto MainMenu
)

echo Adding all .msu files from %selectedFolder%
for %%f in ("%selectedFolder%\*.msu") do (
    dism /Image:"%MOUNT%" /Add-Package /PackagePath:"%%f"
)
pause
goto MainMenu


:: -------------------------------------------------------------------
:: Exit
:: -------------------------------------------------------------------
:END
echo Exiting...
exit /b
