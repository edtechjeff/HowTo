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
set /p choice=Enter your choice (1-6): 
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
goto End

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

REM #########################################################
REM Export Image
REM #########################################################

:ExportImage
@ECHO OFF
CLS
CD /d %~dp0
SETLOCAL ENABLEDELAYEDEXPANSION
Color 1f
ECHO =========================================================
ECHO EDT 11 - Create Image .wim file Framework Script                
ECHO Copyright (C) Microsoft Corporation. All rights reserved.
ECHO =========================================================
ECHO.
set /p edition=What edition of Windows IE 10 or 11:
set /p build=What Build Number IE 23H2:
#set /p name=Name the Image:

:SETEDITION

Set vEdition=""
Set vIndex=""
Set vDefaultKey=""
cls
ECHO.
ECHO Select Image Edition for %1
ECHO.
ECHO [1] Windows %edition% Education
ECHO [2] Windows %edition% Education N
ECHO [3] Windows %edition% Enterprise
ECHO [4] Windows %edition% Enterprise N
ECHO [5] Windows %edition% Pro 
ECHO [6] Windows %edition% Pro N
ECHO [7] Windows %edition% Pro Education
ECHO [8] Windows %edition% Pro Education N
ECHO [9] Windows %edition% Pro for Workstations
ECHO [10] Windows %edition% Pro N for Workstations
ECHO [11] EXIT
ECHO [12] Start Over
ECHO [13] Main Menu
ECHO.
SET /P vEdition=Select the required Edition: 
IF %ERRORLEVEL%==1 GOTO SETEDITION

IF %vEdition%==1 GOTO Education
IF %vEdition%==2 GOTO Education_N
IF %vEdition%==3 GOTO Enterprise
IF %vEdition%==4 GOTO Enterprise_N
IF %vEdition%==5 GOTO Pro
IF %vEdition%==6 GOTO Pro_N
IF %vEdition%==7 GOTO Pro_Education
IF %vEdition%==8 GOTO Pro_Education_N
IF %vEdition%==9 GOTO Pro_for_Workstations
IF %vEdition%==10 GOTO Pro_N_for_Workstations
IF %vEdition%==11 GOTO END
IF %vEdition%==12 GOTO ExportImage
IF %vEdition%==13 GOTO MainMenu

:Education
SET vIndex=1
SET name=Education
GOTO MOUNTWIM
:Education_N
SET name=Education_N
SET vIndex=2
GOTO MOUNTWIM
:Enterprise
SET name=Enterprise
SET vIndex=3
GOTO MOUNTWIM
:Enterprise_N
SET name=Enterprise_N
SET vIndex=4
GOTO MOUNTWIM
:PRO
SET name=Pro
SET vIndex=5
GOTO MOUNTWIM
:PRO_N
SET name=Pro_N
SET vIndex=6
GOTO MOUNTWIM
:Pro_Education
SET name=Pro_Education
SET vIndex=7
GOTO MOUNTWIM
:Pro_Education_N
SET name=Pro_Education_N
SET vIndex=8
GOTO MOUNTWIM
:Pro_for_Workstations
SET name=Pro_for_Workstations
SET vIndex=9
GOTO MOUNTWIM
:Pro_N_for_Workstations
SET name=Pro_N_for_Workstations
SET vIndex=10
GOTO MOUNTWIM

:MOUNTWIM
ECHO.
ECHO =========================================================
ECHO Exporting Image
ECHO =========================================================
ECHO CALL DISM /export-image /sourceimagefile:source\Windows%edition%\%build%\install.wim /sourceindex:%vIndex% /DestinationImageFile:Images\Windows-%Edition%-%Name%-%build%.wim
CALL DISM /export-image /sourceimagefile:source\Windows%edition%\%build%\install.wim /sourceindex:%vIndex% /DestinationImageFile:Images\Windows-%Edition%-%Name%-%build%.wim
cls
pause
ECHO.
ECHO =========================================================
ECHO Mounting WIM File
ECHO =========================================================
ECHO Dism /Mount-Image /ImageFile:Images\Windows-%Edition%-%Name%-%build%.wim  /index:1 /MountDir:"\Images\mount"
ECHO ATTRIB -h -a -s \images\Mount\Windows\System32\Recovery\winre.wim
Dism /Mount-Image /ImageFile:Images\Windows-%Edition%-%Name%-%build%.wim  /index:1 /MountDir:"\Images\mount"
ATTRIB -h -a -s \images\Mount\Windows\System32\Recovery\winre.wim
cls
ECHO.
ECHO =========================================================
ECHO Mounting WINRE File
ECHO =========================================================
ECHO CALL DISM /Mount-Wim /WimFile:\images\Mount\Windows\System32\Recovery\winre.wim /index:1 /MountDir:\images\WinREMount
CALL DISM /Mount-Wim /WimFile:\images\Mount\Windows\System32\Recovery\winre.wim /index:1 /MountDir:\images\WinREMount
cls
ECHO.
ECHO =========================================================
ECHO Applying Drivers to WinRE
ECHO =========================================================
ECHO DISM /image:\images\WinREMount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
DISM /image:\images\WinREMount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
ECHO DISM /image:\images\WinREMount  /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
DISM /image:\images\WinREMount  /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
cls
ECHO.
ECHO =========================================================
ECHO Applying Drivers to Mounted Image
ECHO =========================================================
ECHO DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\WinPE /recurse /ForceUnsigned
ECHO DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
DISM /image:\images\Mount /Add-Driver /Driver:\Images\Drivers\RSTAT /recurse /ForceUnsigned
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
cls
ECHO =========================================================
ECHO Clean up and store WinRE 
ECHO =========================================================

start powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "\images\Scripts\RemovePackages.ps1"

pause
goto MainMenu

REM #########################################################
REM Add Updates
REM #########################################################

:Updates

CLS
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