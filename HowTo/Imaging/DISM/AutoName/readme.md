---
title: "How to AutoName devices via CSV"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Title
How to AutoName devices via CSV after imaging

---

## Purpose
This process will allow you to create a CSV with serial number and a name that can be applied after imaging. You will need to update your Apply-Image.bat file in order to accomplish this.

---

## The Setup

1. In the scripts directory located on the imaging server under the image directory. Create a folder called AutoName

---

2. Copy the following Files
    1. Apply-Comput4erName.ps1
    2. DevicNames.csv
    3. SetupComplete.cmd
    4. Stage-ComputerName.ps1

---

3. Edit or use the Apply-Image.bat file. This will be added at the very end of the Apply-Image.bat file just after END

```bash
echo Staging computer naming if matched in CSV...
powershell.exe -ExecutionPolicy Bypass -File Z:\Scripts\AutoName\Stage-ComputerName.ps1 -CsvPath Z:\Scripts\AutoName\DeviceNames.csv -OsDrive W:

if errorlevel 1 (
    echo Failed during computer naming stage
    exit /b 1
)

echo Continue with boot files, drivers, unattend, etc...
```

---

4. As you can tell from the code this will be launching Stage-compterName.ps1 and does point to the CSV also. 
***Note:*** The -OsDrive W: is the temporary Drive letter for C while imaging. A wild card was tried but did not work. Being specific to the drive letter which is setup during the imaging process avoided failure.

## The Process
From an end user experiance this is how the process works

1. User will boot into PXE
2. Pick your desired image
3. The device will image normally
4. After it gets done imaging it will run 

```bash
echo Staging computer naming if matched in CSV...
powershell.exe -ExecutionPolicy Bypass -File Z:\Scripts\AutoName\Stage-ComputerName.ps1 -CsvPath Z:\Scripts\AutoName\DeviceNames.csv -OsDrive W:

if errorlevel 1 (
    echo Failed during computer naming stage
    exit /b 1
)

echo Continue with boot files, drivers, unattend, etc...
```

---

5. It will run the Stage-computerName.ps1 and look at the CSV. If there was a match then it will continue on

---

6. It will then copy Apply-Computername.ps1 and SetupComplete.cmd and also create a file called ComputerName.txt all located in C:\windows\Setup\Scripts

---

7. You can then reboot the device. It will do normal 1st run functions. One of them will be to run the SetupComplete.cmd. 
***Note:*** SetupComplete.cmd can be used to run multiple items. In this function we are using it to run the Apply-ComputerName.ps1. 

---

8. At this point the device will rename itself and reboot 

---

9. If you have included an Unattend.xml file with your image it will bypass most of the screens.

---

10. Now that its rebooted and ran through the screens it will be ready to be logged onto and also the name will be set