ECHO OFF
CLS
COLOR 1F
SETLOCAL EnableDelayedExpansion

:MENU
SET IMAGEDRIVE=""
@for %%a in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do @if exist %%a:\Images\ set IMAGESDRIVE=%%a
SET M=""
CLS
ECHO =========================================================
ECHO EDT 11 - Image Deployment Framework                
ECHO Copyright (C) Microsoft Corporation. All rights reserved.
ECHO =========================================================
ECHO.
ECHO [1] - Apply .wim file
ECHO [2] - Capture .wim file
ECHO [3] - Open new CMD Window
ECHO [4] - Exit and Reboot
ECHO [5] - Copy AutoPilotProfile

ECHO.
SET /P M=Select Option then press ENTER: 
IF %M%==1 GOTO APPLYWIM
IF %M%==2 GOTO CAPTUREWIM
IF %M%==3 GOTO NEWWIN
IF %M%==4 GOTO EOF
IF %M%==5 GOTO COPYAUTOPILOTPROFILE

:APPLYWIM
ECHO.
SET count=0
SET choice_options=""
FOR /F "delims=" %%A in ('dir /a:-d /b %IMAGESDRIVE%:\Images\*.wim') do (
    REM Increment %count% here so that it doesn't get incremented later
    SET /a count+=1

    REM Add the file name to the options array
    SET "options[!count!]=%%A"

    REM Add the new option to the list of existing options
    SET choice_options=!choice_options!!count!
)
FOR /L %%A in (1,1,!count!) do echo [%%A] - !options[%%A]!
ECHO.
CHOICE /c:!choice_options! /n /m "Select Option: "
ECHO Apply-Image.bat "%IMAGESDRIVE%:\Images\!options[%errorlevel%]!"
CALL Apply-Image.bat "%IMAGESDRIVE%:\Images\!options[%errorlevel%]!"
PAUSE
GOTO MENU

:CAPTUREWIM
Call Capture-Image.cmd
GOTO MENU

:NEWWIN
START CMD
GOTO MENU

:COPYAUTOPILOTPROFILE
@echo off
setlocal enabledelayedexpansion

ECHO.
SET count=0
SET choice_options=""

REM Populate the options list
FOR /F "delims=" %%A in ('dir /a:-d /b "%IMAGESDRIVE%:\AutoPilotConfigurationFiles\*.json"') do (
    SET /a count+=1
    SET "options[!count!]=%%A"
    SET choice_options=!choice_options!!count!
)

REM Display the options
FOR /L %%A in (1,1,!count!) do echo [%%A] - !options[%%A]!
ECHO.

CHOICE /c:!choice_options! /n /m "Select Option: "

REM Build source and destination paths
SET "source=%IMAGESDRIVE%:\AutoPilotConfigurationFiles\!options[%errorlevel%]!"
SET "destination=W:\windows\Provisioning\Autopilot\AutopilotConfigurationFile.json"

REM Copy and rename the selected file
COPY /Y "%source%" "%destination%"

ECHO File copied to AutopilotConfigurationFile.json successfully.
PAUSE
GOTO MENU


:EOF
Exit