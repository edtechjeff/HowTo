# Pre-staging Printer Drivers via Microsoft Intune

## Overview

This method allows you to **pre-stage printer drivers into the Windows driver store** using Microsoft Intune. This ensures the driver is available on the device **before the printer is installed or connected**.

This approach works best with:

* **V4 (Type 4) drivers**
* **Signed, package-aware drivers**

---

## Key Concept

This process **does NOT install a printer**.

It only:

* Adds the driver to the **Windows driver store**
* Makes the driver available for later use (printer deployment, scripts, GPO, etc.)

---

## Prerequisites

* Driver package must include:

  * `.INF` file
  * Associated driver files
* Driver should be:

  * Digitally signed
  * Package-aware (recommended)
* Deployment must run in:

  * **SYSTEM context (Intune Win32 app)**

---

## Folder Structure

```text
PrinterDriver-Prestage
├── install.ps1
├── uninstall.ps1
├── detect.ps1
└── driver
    ├── KOAWNJ__.inf
    ├── *.dll
    ├── *.cat
    └── other driver files
```

---

## Install Script (install.ps1)

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$DriverFolder = Join-Path $PSScriptRoot "driver"
$InfName = "KOAWNJ__.inf"
$InfFile = Join-Path $DriverFolder $InfName

$LogPath = "C:\ProgramData\PrinterDriverPrestage\install.log"
New-Item -ItemType Directory -Path (Split-Path $LogPath) -Force | Out-Null
Start-Transcript -Path $LogPath -Append

try {
    # Ensure correct pnputil path (handles 32/64-bit context)
    $PnpUtil = "$env:WINDIR\SysNative\pnputil.exe"
    if (-not (Test-Path $PnpUtil)) {
        $PnpUtil = "$env:WINDIR\System32\pnputil.exe"
    }

    if (-not (Test-Path $DriverFolder)) {
        Write-Host "Driver folder not found: $DriverFolder"
        exit 1
    }

    # Expand compressed files if present (e.g. .DL_ → .DLL)
    Get-ChildItem -Path $DriverFolder -File | Where-Object { $_.Extension -match '_$' } | ForEach-Object {
        $source = $_.FullName
        $dest = $_.FullName.Substring(0, $_.FullName.Length - 1)

        if (-not (Test-Path $dest)) {
            Write-Host "Expanding $source to $dest"
            & expand.exe $source $dest | Out-Null
        }
    }

    if (-not (Test-Path $InfFile)) {
        Write-Host "INF file not found: $InfFile"
        exit 1
    }

    Write-Host "Installing printer driver package..."
    Write-Host "INF: $InfFile"

    $proc = Start-Process -FilePath $PnpUtil `
        -ArgumentList "/add-driver `"$InfFile`" /install" `
        -Wait -PassThru -NoNewWindow

    Write-Host "pnputil exit code: $($proc.ExitCode)"

    if ($proc.ExitCode -eq 0) {
        Write-Host "Driver package installed successfully."
        exit 0
    } else {
        Write-Host "Driver installation failed."
        exit 1
    }
}
catch {
    Write-Host "Installation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Stop-Transcript | Out-Null
}
```

---

## Detection Script (detect.ps1)

Used by Intune to determine if the driver is already staged.

```powershell
[CmdletBinding()]
param()

$InfName = "KOAWNJ__.inf"

$PnpUtil = "$env:WINDIR\SysNative\pnputil.exe"
if (-not (Test-Path $PnpUtil)) {
    $PnpUtil = "$env:WINDIR\System32\pnputil.exe"
}

try {
    $result = & $PnpUtil /enum-drivers | Select-String -Pattern [regex]::Escape($InfName)

    if ($result) {
        Write-Host "Driver detected in driver store: $InfName"
        exit 0
    }
    else {
        Write-Host "Driver not found in driver store: $InfName"
        exit 1
    }
}
catch {
    Write-Host "Detection failed: $($_.Exception.Message)"
    exit 1
}
```

---

## Uninstall Script (uninstall.ps1)

Removes the driver package and any printers using it.

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$InfFileName = "KOAWNJ__.inf"
$DriverNameMatch = "KONICA MINOLTA"

$LogPath = "C:\ProgramData\PrinterDriverPrestage\uninstall.log"
New-Item -ItemType Directory -Path (Split-Path $LogPath) -Force | Out-Null
Start-Transcript -Path $LogPath -Append

try {
    $PnpUtil = "$env:WINDIR\SysNative\pnputil.exe"
    if (-not (Test-Path $PnpUtil)) {
        $PnpUtil = "$env:WINDIR\System32\pnputil.exe"
    }

    Write-Host "Searching for driver INF: $InfFileName"
    $drivers = & $PnpUtil /enum-drivers

    $blocks = @()
    $current = @()

    foreach ($line in $drivers) {
        if ($line -match "^Published Name\s*:") {
            if ($current.Count -gt 0) { $blocks += ,@($current) }
            $current = @($line)
        }
        elseif ($current.Count -gt 0) {
            $current += $line
        }
    }

    if ($current.Count -gt 0) { $blocks += ,@($current) }

    $targets = foreach ($block in $blocks) {
        $published = ""
        $original  = ""
        $className = ""

        foreach ($line in $block) {
            if ($line -match "Published Name\s*:\s*(.+)$") { $published = $Matches[1].Trim() }
            if ($line -match "Original Name\s*:\s*(.+)$")  { $original  = $Matches[1].Trim() }
            if ($line -match "Class Name\s*:\s*(.+)$")     { $className = $Matches[1].Trim() }
        }

        if ($published -and $original -ieq $InfFileName -and $className -match "Printer") {
            [PSCustomObject]@{
                PublishedName = $published
                OriginalName  = $original
            }
        }
    }

    if (-not $targets) {
        Write-Host "No matching driver found."
        exit 0
    }

    Write-Host "Removing printers using this driver..."
    Get-Printer -ErrorAction SilentlyContinue | Where-Object {
        $_.DriverName -like "*$DriverNameMatch*"
    } | ForEach-Object {
        Write-Host "Removing printer: $($_.Name)"
        Remove-Printer -Name $_.Name -ErrorAction SilentlyContinue
    }

    foreach ($t in $targets) {
        Write-Host "Removing driver package: $($t.PublishedName)"
        Start-Process -FilePath $PnpUtil `
            -ArgumentList "/delete-driver $($t.PublishedName) /uninstall /force" `
            -Wait -NoNewWindow
    }

    Write-Host "Driver removal complete."
    exit 0
}
catch {
    Write-Host "Uninstall failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Stop-Transcript | Out-Null
}
```

---

## Intune Deployment Configuration

### App Type

* **Windows app (Win32)**

### Install Command

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1
```

### Uninstall Command

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\uninstall.ps1
```

### Detection Rule

* Type: **Custom script**
* Script: `detect.ps1`
* Success code: `0`

### Execution Context

* **System**

---

## Validation

To manually verify the driver is staged:

```cmd
pnputil /enum-drivers | findstr /i "KOAWNJ__.inf"
```

Expected output:

```text
Original Name:      KOAWNJ__.inf
Provider Name:      KONICA MINOLTA
```

---

## Notes & Best Practices

* V4 drivers are preferred over V3 drivers
* Always test on:

  * Windows 10
  * Windows 11
* Avoid unsigned drivers
* Pre-staging does NOT:

  * Create a printer
  * Create a port
  * Assign a queue

---

## When to Use This Method

This is ideal when:

* You want **faster printer deployment later**
* You are using:

  * Intune scripts
  * Universal Print
  * Print server migration
* You want to **separate driver install from printer creation**

---

## Summary

This method provides a **clean, scalable way** to manage printer drivers in Intune by:

* Pre-loading drivers
* Reducing user disruption
* Simplifying later printer deployments

---
