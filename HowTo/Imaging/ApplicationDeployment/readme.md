# InProgress
## Process to install applications post deployment of image ***Not Tested*** as of June 4th 2025

1. Mount your Windows image:
```
dism /mount-wim /wimfile:C:\Images\install.wim /index:1 /mountdir:C:\mount
```
2. Create required folders in the mounted image:
```
mkdir C:\mount\Windows\Setup\Scripts
mkdir C:\mount\Installers
```
3. Place your installation files and script:
```
Put your installer EXEs or MSIs in C:\mount\Installers
Create a SetupComplete.cmd file in C:\mount\Windows\Setup\Scripts
```
4. Example SetupComplete.cmd:
```
@echo off
:: Install Chrome silently
start /wait "" "C:\Installers\ChromeSetup.exe" /silent /install

:: Install 7-Zip silently
start /wait "" "C:\Installers\7z.msi" /qn

:: Log output
echo %date% %time% Installation complete >> C:\Installers\install-log.txt

exit 0
```
5. Commit and unmount the image:
```
dism /unmount-wim /mountdir:C:\mount /commit
```