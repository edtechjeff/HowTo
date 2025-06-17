@echo off
COLOR 1F
:MainMenu
cls
echo.
echo 1. Mount Image
echo 2. Export Image
echo 3. Finalize Image
echo 4. Add Drivers
echo 5. Remove Packages
echo 6. Add Updates
echo 7. Exit


echo.
set /p choice=Enter your choice (1-7): 
if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
if "%choice%"=="4" goto option4
if "%choice%"=="5" goto option5
if "%choice%"=="6" goto option6
if "%choice%"=="7" goto option7
echo Invalid choice, please choose a number between 1 and 7.

goto MainMenu

:option1
echo You chose Option 1
cls
goto MountImage

:option2
echo You chose Option 2
cls
goto ExportImage

:option3
echo You chose Option 3
cls
goto UnmountMenu

:option4
echo You chose Option 4
cls
goto AddDrivers

:option5
echo You chose Option 5
cls
goto RemovePackages

:option6
echo You chose Option 6
cls
goto Updates

:option7
echo You chose Option 7
cls
goto END

REM #########################################################
REM Mount Image
REM #########################################################

:MountImage
@echo off
CLS
COLOR 1F
setlocal EnableDelayedExpansion
SET IMAGEDRIVE="%imagedrive%"

:: Create an array of files
set i=0
for %%a in (\images\images\*) do (
    set /A i+=1
    set "file[!i!]=%%~a"
)

ECHO =========================================================
ECHO Please select the image you want to mount         
ECHO =========================================================

:: Display menu
echo Select a file:
for /L %%i in (1,1,%i%) do echo %%i. !file[%%i]!

:: Get user selection
set /P "choice=Enter your choice: "

:: Check if the choice is empty
if not defined choice (
    echo Invalid input, please do not leave the input empty.
    goto MountImage
)

:: Check if the choice is a number
echo %choice%|findstr /R "^[0-9]*$">nul
if %errorlevel% neq 0 (
    echo Invalid input, please enter a number.
    goto MountImage
)

:: Check if the choice is within the valid range
set "selectedFile=!file[%choice%]!"
if not defined selectedFile (
    echo Invalid choice, please try again.
    goto MountImage
)

cls
echo You selected: %selectedFile%

:: Now you can use the variable %selectedFile% in your script

ECHO Dism /Mount-Image /ImageFile:%selectedFile%  /index:1 /MountDir:\images\mount"
Dism /Mount-Image /ImageFile:%selectedFile%  /index:1 /MountDir:\images\mount

goto MainMenu

REM #########################################################
REM Add Drivers
REM #########################################################

:AddDrivers

CLS
COLOR 1F
setlocal EnableDelayedExpansion

:: Create an array of directories
set i=0
for /D %%a in (\images\drivers\*) do (
    set /A i+=1
    set "folder[!i!]=%%~a"
)

ECHO =========================================================
ECHO Please select the drivers you want                
ECHO =========================================================

:: Display menu
echo Select a directory:
for /L %%i in (1,1,%i%) do echo %%i. !folder[%%i]!

:: Get user selection
set /P "choice=Enter your choice: "

:: Check if the choice is empty
if not defined choice (
    echo Invalid input, please do not leave the input empty.
    goto menu
)

:: Check if the choice is a number
echo %choice%|findstr /R "^[0-9]*$">nul
if %errorlevel% neq 0 (
    echo Invalid input, please enter a number.
    goto menu
)

:: Check if the choice is within the valid range
set "selectedFolder=!folder[%choice%]!"
if not defined selectedFolder (
    echo Invalid choice, please try again.
    goto menu
)

echo You selected: %selectedFolder%


:: Now you can use the variable %selectedFolder% in your script
echo DISM /Image:\images\Mount /Add-Driver /Driver:%selectedFolder% /recurse /ForceUnsigned
DISM /Image:\images\Mount /Add-Driver /Driver:%selectedFolder% /recurse /ForceUnsigned

goto MainMenu
cls

REM #########################################################
REM Commit or Discard Image
REM #########################################################
cls
@echo off
setlocal EnableDelayedExpansion

ECHO =========================================================
ECHO Commit or Discard Image                
ECHO =========================================================

:UnmountMenu
:: Display menu
echo Please select an option:
echo 1. Commit Image
echo 2. Discard Image

:: Get user selection
set /P "choice=Enter your choice: "

:: Check if the choice is empty
if not defined choice (
    echo Invalid input, please do not leave the input empty.
    goto UnmountMenu
)

:: Check if the choice is alphanumeric
echo %choice%|findstr /R "^[a-zA-Z0-9]*$">nul
if %errorlevel% neq 0 (
    echo Invalid input, please enter an alphanumeric option.
    goto UnmountMenu
)

:: Check if the choice is one of the valid options
if not "%choice%"=="1" if not "%choice%"=="2" (
    echo Invalid choice, please try again.
    goto UnmountMenu
)

echo You selected: Option %choice%

:: Now you can use the variable %choice% in your script

:: Add if else statement for different commands

cls

if "%choice%"=="1" (
    echo Running command to Approve Drivers
    Dism /Unmount-Image /MountDir:\images\mount /commit
) else (
    echo Running command for Discard Drivers
    Dism /Unmount-Image /MountDir:\images\mount /discard
)

goto MainMenu

:ExportImage
REM #########################################################
REM Export Image
REM #########################################################

@echo off
setlocal EnableDelayedExpansion
color 1F

:: Automatically determine the script's directory
set "BASEDIR=%~dp0"

:: Set WIM path relative to the script's location
set "WIMFILE=%BASEDIR%\source\Windows11\24H2\install.wim"

:: Check if the file exists
if not exist "%WIMFILE%" (
    echo ERROR: WIM file not found at %WIMFILE%
    pause
    exit /b
)

:: Ensure the images directory exists
if not exist "%BASEDIR%images\" (
    mkdir "%BASEDIR%images"
)

:: Temp file for DISM output
set "TMPFILE=%TEMP%\wiminfo.txt"

:: List and parse WIM info
echo.
echo =========================================================
echo Listing available images in: %WIMFILE%
echo =========================================================
echo.

dism /Get-WimInfo /WimFile:"%WIMFILE%" > "%TMPFILE%"

:: Initialize variables
set "index="
set "name="

:: Read DISM output and extract Index and Name lines
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
:: Add .wim extension if missing
echo %outfile% | findstr /i "\.wim$" >nul
if errorlevel 1 set "outfile=%outfile%.wim"


:: Export to \images subfolder under script location
set "DESTWIM=%BASEDIR%images\%outfile%"

echo.
echo =========================================================
echo Exporting Index %index% to %DESTWIM%
echo =========================================================
echo.
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%index% /DestinationImageFile:"%DESTWIM%" /Compress:max /CheckIntegrity

echo.
echo Export completed.
pause

GOTO MOUNTWIM

:MOUNTWIM
ECHO.
ECHO =========================================================
ECHO Mounting WIM File
ECHO =========================================================
ECHO Dism /Mount-Image /ImageFile:%DESTWIM%  /index:1 /MountDir:"\Images\mount"
ECHO ATTRIB -h -a -s \images\Mount\Windows\System32\Recovery\winre.wim
Dism /Mount-Image /ImageFile:%DESTWIM%  /index:1 /MountDir:"\Images\mount"
ATTRIB -h -a -s \images\Mount\Windows\System32\Recovery\winre.wim
pause
cls
ECHO.
ECHO =========================================================
ECHO Mounting WINRE File
ECHO =========================================================
ECHO CALL DISM /Mount-Wim /WimFile:\images\Mount\Windows\System32\Recovery\winre.wim /index:1 /MountDir:\images\WinREMount
CALL DISM /Mount-Wim /WimFile:\images\Mount\Windows\System32\Recovery\winre.wim /index:1 /MountDir:\images\WinREMount
pause
cls
ECHO.
ECHO =========================================================
ECHO Applying Drivers
ECHO =========================================================
ECHO DISM /image:\images\WinREMount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
ECHO DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
DISM /image:\images\WinREMount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
DISM /image:\images\WinREMount /Add-Driver /Driver:\Images\Drivers\VirtIONetwork /recurse /ForceUnsigned
cls
ECHO.
ECHO =========================================================
ECHO Creating Panther Directory
ECHO =========================================================
set "dirPath=\images\Mount\Windows\Panther"
if not exist "%dirPath%" (
    echo Directory does not exist. Creating now...
    md "%dirPath%"
    echo Directory created.
) else (
    echo Directory already exists. Doing nothing.
)

cls
ECHO.
ECHO =========================================================
ECHO Removing Packages
ECHO =========================================================

REM Call PowerShell to remove provisioned appx packages

start powershell -NoProfile -ExecutionPolicy Bypass -File "\images\Scripts\RemovePackages.ps1"
pause
ECHO  Please Wait for script to finish

:FINISH
REM -------------- Clean up and unmount Windows and WinRE
cls
ECHO.
ECHO =========================================================
ECHO Clean up and store WinRE 
ECHO =========================================================
ECHO CALL DISM /image:\images\WinREMount /Cleanup-image /StartComponentCleanup
CALL DISM /image:\images\WinREMount /Cleanup-image /StartComponentCleanup
ECHO CALL DISM /unmount-image /mountdir:\images\WinREMount /commit
CALL DISM /unmount-image /mountdir:\images\WinREMount /commit
ECHO CALL DISM /unmount-image /mountdir:\images\Mount /commit
CALL DISM /unmount-image /mountdir:\images\Mount /commit

GOTO MainMenu

:RemovePackages
REM #########################################################
REM Remove Packages
REM #########################################################
cls
ECHO =========================================================
ECHO Clean up and store WinRE 
ECHO =========================================================

start powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "\images\Scripts\RemovePackages.ps1"
pause
ECHO  Please Wait for script to finish
goto MainMenu

:RemovePackages
cls
ECHO =========================================================
ECHO Clean up and store WinRE 
ECHO =========================================================

start powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "\images\Scripts\RemovePackages.ps1"

pause
goto MainMenu

:Updates
CLS
ECHO =========================================================
ECHO Add Updates
ECHO =========================================================

COLOR 1F
setlocal EnableDelayedExpansion

:: Create an array of directories
set i=0
for /D %%a in (\images\Updates\*) do (
    set /A i+=1
    set "folder[!i!]=%%~a"
)

ECHO =========================================================
ECHO Please select the updates you want                
ECHO =========================================================

:: Display menu
echo Select a directory:
for /L %%i in (1,1,%i%) do echo %%i. !folder[%%i]!

:: Get user selection
set /P "choice=Enter your choice: "

:: Check if the choice is empty
if not defined choice (
    echo Invalid input, please do not leave the input empty.
    goto menu
)

:: Check if the choice is a number
echo %choice%|findstr /R "^[0-9]*$">nul
if %errorlevel% neq 0 (
    echo Invalid input, please enter a number.
    goto menu
)

:: Check if the choice is within the valid range
set "selectedFolder=!folder[%choice%]!"
if not defined selectedFolder (
    echo Invalid choice, please try again.
    goto menu
)

echo You selected: %selectedFolder%


:: Now you can use the variable %selectedFolder% in your script
echo for %%F in ("%selectedFolder%") do set "folderName=%%~nxF"
echo DISM /Add-Package /Image:\images\Mount /PackagePath=%selectedFolder%\%folderName%.msu
REM for %%F in ("%selectedFolder%") do set "folderName=%%~nxF"
REM DISM /Add-Package /Image:\images\Mount /PackagePath=%selectedFolder%\%folderName%.msu
echo Adding all .msu files from: %selectedFolder%
for %%f in ("%selectedFolder%\*.msu") do (
    echo Adding package: %%f
    DISM /Add-Package /Image:\images\Mount /PackagePath:"%%f"
)

pause
goto MainMenu
cls


:END
COLOR 0F