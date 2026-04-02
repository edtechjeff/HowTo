# Printer Deployment via Microsoft Intune (Using Pre-Staged Drivers)

## Overview

This guide provides a **standardized method to deploy printers using Microsoft Intune** after the printer driver has already been **pre-staged into the Windows driver store**.

This method is designed for:

* Group-based printer assignments
* Simple, repeatable deployments
* Environments using **direct IP printers**
* Separation of driver management and printer deployment

---

## Architecture

This deployment uses two components:

### 1. Driver Pre-Staging (Required First Step)

* Deploy driver via Win32 app
* Installs driver into Windows driver store

### 2. Printer Deployment (This Guide)

* Creates:

  * TCP/IP Port
  * Printer Queue
  * Driver binding

---

## Requirements

* Printer driver must already be installed (pre-staged)
* Printer must be reachable via IP
* Deployment must run as:

  * **SYSTEM context**
* Printer must support:

  * Standard TCP/IP printing (RAW 9100 or LPR)

---

## Folder Structure

```text
Printer-Deploy-App
├── install.ps1
├── uninstall.ps1
└── detect.ps1
```

---

## Install Script (install.ps1)

This script:

* Creates the printer port (if needed)
* Creates the printer (if not present)
* Assigns the correct driver

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# CONFIGURATION
$PrinterName = "Front Office Printer"
$PrinterIP   = "192.168.1.50"
$DriverName  = "KONICA MINOLTA Universal PCL"
$PortName    = "IP_$PrinterIP"

$LogPath = "C:\ProgramData\PrinterDeployment\install.log"
New-Item -ItemType Directory -Path (Split-Path $LogPath) -Force | Out-Null
Start-Transcript -Path $LogPath -Append

try {
    Write-Host "Starting printer installation..."

    # Ensure port exists
    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
        Write-Host "Creating printer port: $PortName"
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP
    }
    else {
        Write-Host "Printer port already exists: $PortName"
    }

    # Ensure printer exists
    if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
        Write-Host "Creating printer: $PrinterName"

        Add-Printer `
            -Name $PrinterName `
            -DriverName $DriverName `
            -PortName $PortName

        Write-Host "Printer created successfully."
    }
    else {
        Write-Host "Printer already exists: $PrinterName"
    }

    # Optional: Configure printer settings
    Write-Host "Applying printer configuration..."
    Set-PrintConfiguration `
        -PrinterName $PrinterName `
        -DuplexingMode TwoSidedLongEdge `
        -Color $true

    Write-Host "Printer deployment complete."
    exit 0
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

This script checks if the printer is installed.

```powershell
[CmdletBinding()]
param()

$PrinterName = "Front Office Printer"

try {
    $printer = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue

    if ($printer) {
        Write-Host "Printer detected: $PrinterName"
        exit 0
    }
    else {
        Write-Host "Printer not found: $PrinterName"
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

This script removes:

* Printer queue
* Printer port (if not in use)

```powershell
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$PrinterName = "Front Office Printer"
$PrinterIP   = "192.168.1.50"
$PortName    = "IP_$PrinterIP"

$LogPath = "C:\ProgramData\PrinterDeployment\uninstall.log"
New-Item -ItemType Directory -Path (Split-Path $LogPath) -Force | Out-Null
Start-Transcript -Path $LogPath -Append

try {
    Write-Host "Starting printer removal..."

    # Remove printer
    if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
        Write-Host "Removing printer: $PrinterName"
        Remove-Printer -Name $PrinterName
    }
    else {
        Write-Host "Printer not found: $PrinterName"
    }

    # Remove port if not used
    $portInUse = Get-Printer | Where-Object { $_.PortName -eq $PortName }

    if (-not $portInUse) {
        if (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue) {
            Write-Host "Removing printer port: $PortName"
            Remove-PrinterPort -Name $PortName
        }
    }
    else {
        Write-Host "Port still in use, not removing: $PortName"
    }

    Write-Host "Printer removal complete."
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

# 🔗 Dependency Configuration (CRITICAL)

## Why This Is Required

This printer deployment **depends on the driver already being installed**.

If the driver is not present:

* Printer creation will fail
* Deployment will be unreliable

---

## What Dependencies Do

Dependencies ensure:

* Driver installs **before** printer deployment
* Intune verifies driver installation via detection
* Printer script runs only after driver is confirmed

---

## How to Configure Dependency in Intune

1. Go to:

   * **Intune Admin Center**
2. Navigate to:

   * Apps → Windows
3. Select:

   * **Printer Deployment App**
4. Click:

   * **Properties**
5. Scroll to:

   * **Dependencies**
6. Click:

   * **Edit**
7. Click:

   * **Add**
8. Select:

   * Your **Printer Driver Win32 App**
9. Click:

   * **Save**

---

## Deployment Flow with Dependency

```text
1. Printer App assigned to device/group
2. Intune detects dependency (Driver App)
3. Driver App installs
4. Driver detection runs (INF present) ✔
5. Printer App installs
6. Printer detection runs ✔
```

---

## Important Behavior

* Intune will **NOT run the printer app** until:

  * Driver app installs successfully
  * Driver detection returns success (`exit 0`)
* If driver detection fails:

  * Intune retries driver install
  * Printer app never runs

---

## Dependency Best Practices

* Do NOT assign driver app directly (recommended)
* Use driver app only as:

  * **Dependency**
* Use **one driver app for multiple printers**
* Ensure driver detection is:

  * Accurate
  * Based on INF presence

---

## Example Architecture

```text
Driver App: KONICA Universal Driver
    ↓ dependency

Printer Apps:
├── Printer - Front Office
├── Printer - Warehouse
├── Printer - HR
```

---

## Intune Configuration

### App Type

* Windows app (Win32)

---

### Install Command

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1
```

---

### Uninstall Command

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\uninstall.ps1
```

---

### Detection Rule

* Type: **Custom script**
* Script: `detect.ps1`
* Exit Code:

  * `0` = Installed
  * `1` = Not Installed

---

### Assignments

* Assign the app to:

  * Device groups OR
  * User groups

---

## Validation

### Check Printer

```powershell
Get-Printer -Name "Front Office Printer"
```

---

### Check Port

```powershell
Get-PrinterPort -Name "IP_192.168.1.50"
```

---

## Best Practices

* Always pre-stage drivers before deploying printers
* Always configure dependencies
* Keep driver and printer deployments separate
* Use consistent naming conventions
* Log all actions for troubleshooting

---

## Summary

This method provides a **clean and reliable printer deployment model**:

* Drivers are pre-staged
* Dependencies enforce correct install order
* Printers deploy via group assignment
* Deployments are repeatable and scalable

---
