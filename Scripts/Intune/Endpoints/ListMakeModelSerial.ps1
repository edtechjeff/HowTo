# ==============================
# Script: Get Intune Device Info
# ==============================

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Confirm connection
$context = Get-MgContext
Write-Host "Connected as: $($context.Account)"

# Get Intune managed devices
Write-Host "Retrieving device data from Intune..."
$devices = Get-MgDeviceManagementManagedDevice -All

# Select relevant fields
$deviceInfo = $devices | Select-Object DeviceName, Manufacturer, Model, SerialNumber

# Ensure C:\Temp exists
$exportFolder = "C:\Temp"
if (-not (Test-Path -Path $exportFolder)) {
    New-Item -Path $exportFolder -ItemType Directory -Force
    Write-Host "Created folder: $exportFolder"
}

# Export to CSV
$exportPath = Join-Path $exportFolder "Intune_Device_Inventory.csv"
$deviceInfo | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "`nExported device information to: $exportPath"

Disconnect-MgGraph