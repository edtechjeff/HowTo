@echo off
setlocal EnableExtensions EnableDelayedExpansion
COLOR 1F

:: ==========================================================
:: SELF ELEVATION
:: ==========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:: ==========================================================
:: PATHS
:: ==========================================================

set "BASE=%~dp0"
set "IMAGES=%BASE%Images"
set "MOUNT=%BASE%Mount"
set "WINRE=%BASE%WinREMount"
set "DRIVERS=%BASE%Drivers"
set "UPDATES=%BASE%Updates"
set "SCRIPTS=%BASE%Scripts"

:: ==========================================================
:MainMenu
cls
echo.
echo 1. Mount Image
echo 2. Export Image
echo 3. Finalize Image
echo 4. Add Drivers
echo 5. Exit
echo.
set /p choice=Enter your choice (1-7):

if "%choice%"=="1" goto MountImage
if "%choice%"=="2" goto ExportImage
if "%choice%"=="3" goto UnmountMenu
if "%choice%"=="4" goto AddDrivers
if "%choice%"=="5" goto End
goto MainMenu

:: ==========================================================
:: MOUNT IMAGE (FIXED)
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
if not exist "!selectedFile!" (
    echo ERROR: File not found!
    pause
    goto MountImage
)

if not exist "%MOUNT%" mkdir "%MOUNT%"

echo.
echo Mounting:
echo !selectedFile!
echo.

DISM /Mount-Image ^
 /ImageFile:"!selectedFile!" ^
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
if not exist "!selectedFolder!" goto AddDrivers

DISM /Image:"%MOUNT%" /Add-Driver /Driver:"!selectedFolder!" /Recurse /ForceUnsigned

pause
goto MainMenu

:: ==========================================================
:: EXPORT IMAGE
:: ==========================================================
:ExportImage
cls
setlocal EnableDelayedExpansion

set /p edition=Windows version (10 or 11):
set /p build=Build (e.g. 23H2):

set "WIM=source\Windows%edition%\%build%\install.wim"

echo Reading available images...

set count=0
for /f "tokens=2 delims=: " %%A in ('dism /Get-WimInfo /WimFile:"%WIM%" ^| findstr /c:"Index :"') do (
    set /a count+=1
    set index!count!=%%A
)

set nameCount=0
for /f "tokens=2,* delims=: " %%A in ('dism /Get-WimInfo /WimFile:"%WIM%" ^| findstr /c:"Name :"') do (
    set /a nameCount+=1
    set name!nameCount!=%%B
)

echo =========================
echo Available Editions
echo =========================
for /l %%i in (1,1,!count!) do (
    echo %%i^) !name%%i! (Index !index%%i!)
)

set /p choice=Select edition:

if not defined index%choice% (
    echo Invalid selection.
    pause
    goto ExportImage
)

set selectedIndex=!index%choice%!

if not exist "%IMAGES%" mkdir "%IMAGES%"

set "FINALWIM=%IMAGES%\Windows-%edition%-%build%.wim"

DISM /Export-Image ^
 /SourceImageFile:"%WIM%" ^
 /SourceIndex:!selectedIndex! ^
 /DestinationImageFile:"!FINALWIM!"

echo.
echo Export complete: !FINALWIM!
pause

:: ==========================================================
:: MOUNT EXPORTED IMAGE
:: ==========================================================
cls
echo Mounting exported WIM...

if not exist "!FINALWIM!" (
    echo ERROR: WIM not found!
    pause
    goto MainMenu
)

if not exist "%MOUNT%" mkdir "%MOUNT%"

DISM /Mount-Image ^
 /ImageFile:"!FINALWIM!" ^
 /Index:1 ^
 /MountDir:"%MOUNT%"

:: ==========================================================
:: HANDLE WINRE
:: ==========================================================
echo Preparing WinRE...

if exist "%MOUNT%\Windows\System32\Recovery\winre.wim" (
    attrib -h -a -s "%MOUNT%\Windows\System32\Recovery\winre.wim"

    if not exist "%WINRE%" mkdir "%WINRE%"

    DISM /Mount-Wim ^
     /WimFile:"%MOUNT%\Windows\System32\Recovery\winre.wim" ^
     /Index:1 ^
     /MountDir:"%WINRE%"
)

pause

:: ==========================================================
:: APPLY DRIVERS TO WINRE
:: ==========================================================
echo =========================================================
echo Applying Drivers to WinRE
echo =========================================================

DISM /Image:\Images\WinREMount /Add-Driver /Driver:\Images\Drivers\WinPE /Recurse /ForceUnsigned
DISM /Image:\Images\WinREMount /Add-Driver /Driver:\Images\Drivers\RSTAT /Recurse /ForceUnsigned

pause
cls

:: ==========================================================
:: APPLY DRIVERS TO OS IMAGE
:: ==========================================================
echo =========================================================
echo Applying Drivers to Mounted Image
echo =========================================================

DISM /Image:\Images\Mount /Add-Driver /Driver:\Images\Drivers\WinPE /Recurse /ForceUnsigned
DISM /Image:\Images\Mount /Add-Driver /Driver:\Images\Drivers\RSTAT /Recurse /ForceUnsigned

pause
cls

:: ==========================================================
:: CREATE PANTHER FOLDER
:: ==========================================================
echo =========================================================
echo Creating Panther Directory
echo =========================================================

set "dirPath=\Images\Mount\Windows\Panther"

if not exist "%dirPath%" (
    echo Creating directory...
    md "%dirPath%"
) else (
    echo Directory already exists.
)

pause
cls

:: ==========================================================
:: REMOVE PACKAGES
:: ==========================================================
echo =========================================================
echo Removing Packages
echo =========================================================

start powershell -NoProfile -ExecutionPolicy Bypass -File "\Images\Scripts\RemovePackages.ps1"

echo Please wait for script to finish...
pause
cls

:: ==========================================================
:: DISABLE CLOUD CONTENT
:: ==========================================================
echo =========================================================
echo Disabling Cloud Content
echo =========================================================

set MountPath=\Images\Mount

reg load HKLM\OFFLINE "%MountPath%\Windows\System32\Config\SOFTWARE"

reg add "HKLM\OFFLINE\Policies\Microsoft\Windows\CloudContent" /f
reg add "HKLM\OFFLINE\Policies\Microsoft\Windows\CloudContent" ^
 /v DisableWindowsConsumerFeatures ^
 /t REG_DWORD ^
 /d 1 ^
 /f

reg unload HKLM\OFFLINE

pause

:: ==========================================================
:: CLEANUP & UNMOUNT
:: ==========================================================
:FINISH
cls
echo =========================================================
echo Cleaning up and unmounting images
echo =========================================================

DISM /Image:\Images\WinREMount /Cleanup-Image /StartComponentCleanup
DISM /Unmount-Image /MountDir:\Images\WinREMount /Commit
DISM /Unmount-Image /MountDir:\Images\Mount /Commit

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
:End
exit /b
``
