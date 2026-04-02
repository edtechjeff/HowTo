# Method to install Printers via PrintBRM

# Intune Printer Deployment (PrintBRM Method)

## Overview

This guide walks through deploying a printer via Microsoft Intune using:

* Printer export from a reference device
* `PrintBRM.exe` for restore
* Win32 app deployment via `.intunewin`

---

## When to Use This Method

Use this method when:

* You already installed the printer manually on a Windows 11 device
* You want to replicate that exact configuration
* You are deploying via Intune as a Win32 app

---

## Prerequisites

* Windows 10/11 reference device
* Printer installed and working
* Intune Win32 packaging tool (`IntuneWinAppUtil.exe`)
* Admin rights on reference machine

---

## Step 1: Create Reference Printer

1. Install printer manually:

   * Correct driver
   * Correct IP/port
   * Desired printer name

2. Verify printing works

---

## Step 2: Export Printer

1. Open **Print Management**
2. Right-click **Print Management**
3. Select **Migrate Printers**
4. Choose:

   * **Export printer queues and printer drivers to a file**
5. Save to:

```
C:\PrinterPackage\OfficePrinter.printerExport
```

---

## Step 3: Create Package Structure

```
C:\PrinterPackage\
│
├── Files\
│   └── OfficePrinter.printerExport
│
├── Install-Printer.ps1
├── Detect-Printer.ps1
└── Uninstall-Printer.ps1
```

---

## Step 4: Install Script

**Install-Printer.ps1**

```powershell
$ErrorActionPreference = 'Stop'

$printerExport = Join-Path $PSScriptRoot 'Files\OfficePrinter.printerExport'
$printBrm = Join-Path $env:WINDIR 'System32\spool\tools\PrintBRM.exe'
$logFolder = Join-Path $env:ProgramData 'Microsoft\IntunePrinterDeploy'
$logFile = Join-Path $logFolder 'Install-Printer.log'

if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $logFile -Value "$timestamp - $Message"
}

try {
    Write-Log "Starting printer restore."

    if (-not (Test-Path $printerExport)) {
        throw "Printer export file not found"
    }

    $arguments = "-R -F `"$printerExport`" -O FORCE"

    $process = Start-Process -FilePath $printBrm `
        -ArgumentList $arguments `
        -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        throw "PrintBRM failed with exit code $($process.ExitCode)"
    }

    Start-Sleep -Seconds 10

    Write-Log "Printer restore successful."
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
```

---

## Step 5: Detection Script

**Detect-Printer.ps1**

```powershell
$printerName = 'Office Printer - Front Office'

$printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

if ($null -ne $printer) {
    exit 0
}
else {
    exit 1
}
```

---

## Step 6: Uninstall Script

**Uninstall-Printer.ps1**

```powershell
$ErrorActionPreference = 'Stop'

$printerName = 'Office Printer - Front Office'

try {
    $printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

    if ($null -ne $printer) {
        Remove-Printer -Name $printerName -ErrorAction Stop
    }

    exit 0
}
catch {
    exit 1
}
```

---

## Step 7: Create IntuneWin Package

Run:

```cmd
IntuneWinAppUtil.exe -c C:\PrinterPackage -s Install-Printer.ps1 -o C:\IntuneOutput
```

---

## Step 8: Intune Configuration

### App Type

* Windows app (Win32)

### Install Command

```cmd
powershell.exe -ExecutionPolicy Bypass -File .\Install-Printer.ps1
```

### Uninstall Command

```cmd
powershell.exe -ExecutionPolicy Bypass -File .\Uninstall-Printer.ps1
```

### Install Behavior

```
System
```

### Detection Rules

* Use custom detection script:

  * Upload `Detect-Printer.ps1`

---

## Step 9: Assignment

* Deploy to test group first
* Validate functionality before production rollout

---

## Troubleshooting

### Logs

```
C:\ProgramData\Microsoft\IntunePrinterDeploy\
```

### Common Issues

| Issue                 | Cause                  |
| --------------------- | ---------------------- |
| Printer not installed | Driver issue           |
| Install fails         | PrintBRM error         |
| Detection fails       | Name mismatch          |
| Works on ref PC only  | Driver incompatibility |

---

## Notes

* Printer name must match exactly in detection script
* Drivers are the most common failure point
* Best run in **System context**
* Always test on one device before broad deployment

---

## Alternative (Recommended for Production)

Instead of PrintBRM, use direct PowerShell:

```powershell
pnputil.exe /add-driver ".\Driver\driver.inf" /install
Add-PrinterDriver -Name "Driver Name"
Add-PrinterPort -Name "IP_192.168.1.50" -PrinterHostAddress "192.168.1.50"
Add-Printer -Name "Office Printer - Front Office" `
    -DriverName "Driver Name" `
    -PortName "IP_192.168.1.50"
```

### Why this is better

* More reliable
* Easier troubleshooting
* Cleaner deployments
* No dependency on export files

---

## Author

Jeff Downs
edtechjeff.com
