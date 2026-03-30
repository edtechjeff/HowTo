---
title: "Adding Additional Command Line Tools to WinPE"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Title: Adding Additional Command Line Tools to WinPE

---

## Purpose: Gives you additional command line tools like Powershell while in PXE\WinPE

---

## Process

***Note:*** In order for this process to work you must have loaded the Windows ADK on the device you are going to run these commmands on. 

---

1. Mount your custom boot image

```bash
dism /mount-wim /wimfile:"boot.wim" /index:1 /mountdir:"C:\WinPEMount"
```

---

2. Run the following commmands in this order

```bash
dism /image:"C:\WinPEMount" /add-package /packagepath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"

dism /image:"C:\WinPEMount" /add-package /packagepath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"

dism /image:"C:\WinPEMount" /add-package /packagepath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"

dism /image:"C:\WinPEMount" /add-package /packagepath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
```

3. Unmount and commit the image 

```bash
dism /unmount-wim /mountdir:"C:\WinPEMount" /commit

```