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

ECHO.
SET /P M=Select Option then press ENTER: 
IF %M%==1 GOTO APPLYWIM
IF %M%==2 GOTO CAPTUREWIM
IF %M%==3 GOTO NEWWIN
IF %M%==4 GOTO EOF

:APPLYWIM
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO.

SET count=0
REM Clear existing options
FOR /F "delims=" %%A in ('dir /a:-d /b "%IMAGESDRIVE%:\Images\*.wim"') do (
    SET /a count+=1
    SET "options[!count!]=%%A"
)

FOR /L %%A in (1,1,!count!) do (
    ECHO [%%A] - !options[%%A]!
)

:PromptChoice
ECHO.
SET /P userChoice="Select option [1-!count!]: "

REM Validate numeric input
SET /A validChoice=%userChoice% 2>NUL
IF "%validChoice%"=="" GOTO InvalidChoice
IF %validChoice% GTR %count% GOTO InvalidChoice
IF %validChoice% LSS 1 GOTO InvalidChoice

ECHO.
ECHO Running Apply-Image.bat with !options[%userChoice%]!
CALL Apply-Image.bat "%IMAGESDRIVE%:\Images\!options[%userChoice%]!"
GOTO MENU
Pause

:InvalidChoice
ECHO Invalid selection. Please choose a number between 1 and %count%.
GOTO PromptChoice


:CAPTUREWIM
Call Capture-Image.cmd
GOTO MENU

:NEWWIN
START CMD
GOTO MENU

:EOF
Exit