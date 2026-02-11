---
title: Device Prerperation Policies using Unattend.xml
author: Jeff Downs
date: Feburary 9, 2026
---

# Gives you the ability to bypass some of the OOBE screen

## Purpose: The goal of this document is to help with the end user experiance with onboarding thier own device using Device Preperation Policies. 

Two options 
- You could create your own custom image and include this unattend.xml as part of your image and use this file. 
- You could also do the following procedure with the built in factory OS.  

***Note: In order for this to work, you will need to sysprep the device***
***Note: The provided link is to my unattend.xml file. Feel free to host your own file with your own configuration***
***Note: Device must have network in order to do the following procedure***

- At the OOBE screen drop into a dos prompt window by pressing Shift + F10
- Check and make a directory called Panther
    - c:\Windows\Panther

- Change to powershell prompt
```bash
powershell
```

- Copy file from github repo
```powershell
Invoke-WebRequest -uri "https://raw.githubusercontent.com/edtechjeff/HowTo/refs/heads/main/HowTo/Intune/DevicePreperationPolicies/unattend.xml" -outfile "c:\windows\panther\unattend.xml"
```

- Change to command prompt
```powershell
cmd
```
- Issue the following command to kick off sysprep

```bash
cd %windir%\system32\sysprep
sysprep /oobe /reboot /unattend:C:\Windows\Panther\unattend.xml
```