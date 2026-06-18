# Purpose: Steps used to create custom Bootable ISO

## Thought Behind the process: If you have created  your own custom boot.wim and would like to burn this to a USB or use it in a virtual environment instead of using PXE for booting you could use this

## Pre-Reqs

- Windows ADK
- Deployment Tools
- WinPE Add-on

**Note** You should have these already loaded if you using this full process

**Note:** Run all commands as administrator

## Run command to pull all the required files.

```bash
copype amd64 C:\WinPE
```

**Note** You do not need to create directory this will do it automatically. 

## Creates basic structure like this

C:\WinPE\
   ├── media\
   │     ├── boot\
   │     ├── efi\
   │     └── sources\

## Replace the boot.wim with your custom boot.wim 

## Build ISO

```bash
MakeWinPEMedia /ISO C:\WinPE C:\ISO\MyBootISO.iso
```

**Note:** The ISO directory will need to be created

