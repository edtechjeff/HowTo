# Install Modules
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Graph
Connect-MgGraph -Scopes "Device.Read.All"

# Define the path to the CSV file containing device IDs
$DeviceListPath = "C:\temp\IntuneDevices.csv"

$Devices = Import-Csv -Path $DeviceListPath

# Create an empty array to store results
$DeviceCheckinData = @()

# Loop through each device and get its last check-in time
foreach ($Device in $Devices) {
    $ObjectId = $Device.ID  # Ensure your CSV has a column named "ID"

    # Query Microsoft Graph for the device by Object ID
    $GraphDevice = Get-MgDevice -Filter "id eq '$ObjectId'" -Property Id, DisplayName, ApproximateLastSignInDateTime

    if ($GraphDevice) {
        # Store the results
        $DeviceCheckinData += [PSCustomObject]@{
            ObjectID       = $GraphDevice.Id
            DeviceName     = $GraphDevice.DisplayName
            LastCheckin    = $GraphDevice.ApproximateLastSignInDateTime
        }
    } else {
        # Device not found
        $DeviceCheckinData += [PSCustomObject]@{
            ObjectID       = $ObjectId
            DeviceName     = "Not Found"
            LastCheckin    = "Not Found"
        }
    }
}


# Export results to a CSV
$DeviceCheckinData | Export-Csv -Path "C:\temp\IntuneDevicesOutPut.csv" -NoTypeInformation

Write-Host "Report generated at C:\temp\IntuneDevicesOutPut.csv"
