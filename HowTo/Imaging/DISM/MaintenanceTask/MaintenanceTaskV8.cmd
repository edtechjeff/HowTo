@echo off
setlocal EnableExtensions EnableDelayedExpansion
COLOR 1F

:: ==========================================================
:: SELF ELEVATION (RUNS ONCE)
:: ==========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ==========================================================
:: FORCE SCRIPT CONTEXT
:: ==========================================================
cd /d "%~dp0"

:: ==========================================================
:: BASE PATH DEFINITIONS
:: ==========================================================
set "BASE=%~dp0"
set "IMAGES=%BASE%images"
set "MOUNT=%IMAGES%\mount"
set "WINRE=%IMAGES%\WinREMount"
set "DRIVERS=%IMAGES%\drivers"
set "UPDATES=%IMAGES%\Updates"
set "SCRIPTS=%BASE%Scripts"

:: ==========================================================
:MainMenu
cls
echo.
echo 1. Mount Image
echo 2. Export Image
echo 3. Finalize Image
echo 4. Add Drivers
echo 5. Remove Packages
echo 6. Exit
echo 7. Add Updates
echo.
set /p choice=Enter your choice (1-7):

if "%choice%"=="1" goto MountImage
if "%choice%"=="2" goto ExportImage
if "%choice%"=="3" goto UnmountMenu
if "%choice%"=="4" goto AddDrivers
if "%choice%"=="5" goto RemovePackages
if "%choice%"=="6" goto End
if "%choice%"=="7" goto Updates

goto MainMenu

:: ==========================================================
:: MOUNT IMAGE
:: ==========================================================
:MountImage
cls
set i=0

for %%a in ("%IMAGES%\*.wim") do (
    set /a i+=1
    set "file[!i!]=%%~fa"
)

if %i%==0 (
    echo No WIM files found in %IMAGES%
    pause
    goto MainMenu
)

echo Select an image to mount:
for /l %%i in (1,1,%i%) do echo %%i. !file[%%i]!

set /p choice=Enter number:
set "selectedFile=!file[%choice%]!"
if not defined selectedFile goto MountImage

echo Mounting:
echo %selectedFile%

Dism /Mount-Image ^
 /ImageFile:"%selectedFile%" ^
 /Index:1 ^
 /MountDir:"%MOUNT%"

pause
goto MainMenu

:: ==========================================================
:: ADD DRIVERS
:: ==========================================================
:AddDrivers
cls
set i=0

for /d %%a in ("%DRIVERS%\*") do (
    set /a i+=1
    set "folder[!i!]=%%~fa"
)

for /l %%i in (1,1,%i%) do echo %%i. !folder[%%i]!

set /p choice=Select driver folder:
set "selectedFolder=!folder[%choice%]!"
if not defined selectedFolder goto AddDrivers

DISM /Image:"%MOUNT%" /Add-Driver /Driver:"%selectedFolder%" /Recurse /ForceUnsigned
pause
goto MainMenu

:: ==========================================================
:: UNMOUNT
:: ==========================================================
:UnmountMenu
cls
echo 1. Commit Image
echo 2. Discard Image
set /p choice=Selection:

if "%choice%"=="1" Dism /Unmount-Image /MountDir:"%MOUNT%" /Commit
if "%choice%"=="2" Dism /Unmount-Image /MountDir:"%MOUNT%" /Discard

pause
goto MainMenu

:: ==========================================================
:: EXPORT IMAGE (UNCHANGED LOGIC, FIXED PATHS)
:: ==========================================================
:ExportImage
cls
set /p edition=Windows version (10 or 11):
set /p build=Build (e.g. 23H2):

echo Exporting image...
DISM /export-image ^
 /sourceimagefile:"source\Windows%edition%\%build%\install.wim" ^
 /sourceindex:1 ^
 /DestinationImageFile:"%IMAGES%\Windows-%edition%-%build%.wim"

pause
goto MainMenu

:: ==========================================================
:: REMOVE PACKAGES
:: ==========================================================
:RemovePackages
start powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%\RemovePackages.ps1"
pause
goto MainMenu

:: ==========================================================
:: UPDATES
:: ==========================================================
:Updates
cls
for %%f in ("%UPDATES%\*.msu") do (
    echo Adding %%f
    DISM /Add-Package /Image:"%MOUNT%" /PackagePath:"%%f"
)
pause
goto MainMenu

:: ==========================================================
:End
exit /b
