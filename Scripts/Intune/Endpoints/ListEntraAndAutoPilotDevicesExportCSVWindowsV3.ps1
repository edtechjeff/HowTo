# Pulls EntrID,DeviceID,SerialNumber,AutoPilotID,DisplayName,ApproximateLastSignInDateTime,OperatingSystem,Make,Model,TrustType

# Import Microsoft Graph Module
Import-Module Microsoft.Graph

# Define required Graph scopes
$scopes = @(
    "Device.Read.All", 
    "Group.ReadWrite.All", 
    "DeviceManagementManagedDevices.Read.All"
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes $scopes

# Ensure output directory exists
$OutputFolder = "C:\Temp"
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}
$OutputFile = "$OutputFolder\FullDeviceList.csv"

# Retrieve Entra ID devices (filtering out non-Windows-like devices)
$Devices = Get-MgDevice -All -Property DisplayName, DeviceId, Id, ApproximateLastSignInDateTime, OperatingSystem, TrustType | 
    Where-Object { $_.OperatingSystem -notin @("iOS", "Android", "macOS", "iPad", "Printer", "iPhone", "MacMDM") } |
    Select-Object DisplayName, DeviceId, Id, ApproximateLastSignInDateTime, OperatingSystem, TrustType

# Retrieve Autopilot device info
$AutopilotDevices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity | 
    Select-Object SerialNumber, Id, AzureActiveDirectoryDeviceId

# Retrieve Intune managed device info (Make/Model)
$IntuneDevices = Get-MgDeviceManagementManagedDevice -All | 
    Select-Object AzureADDeviceId, Manufacturer, Model

# Combine all data into one list
$CombinedList = foreach ($device in $Devices) {
    $autopilot = $AutopilotDevices | Where-Object { $_.AzureActiveDirectoryDeviceId -eq $device.DeviceId }
    $intune = $IntuneDevices | Where-Object { $_.AzureADDeviceId -eq $device.DeviceId }

    [PSCustomObject]@{
        EntraID                        = $device.Id
        DeviceId                       = $device.DeviceId
        SerialNumber                   = $autopilot.SerialNumber
        AutoPilotID                    = $autopilot.Id
        DisplayName                    = $device.DisplayName
        ApproximateLastSignInDateTime  = $device.ApproximateLastSignInDateTime
        OperatingSystem                = $device.OperatingSystem
        TrustType                      = $device.TrustType
        Make                           = $intune.Manufacturer
        Model                          = $intune.Model
    }
}

# Export to CSV
$CombinedList | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "CSV export complete: $OutputFile"

# Disconnect session
Disconnect-MgGraph
