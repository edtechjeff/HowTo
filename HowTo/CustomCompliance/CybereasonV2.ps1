# Initialize output hashtable
$output = @{}

# Check if Cybereason is installed
$cybereasonPath = "C:\Program Files\Cybereason ActiveProbe"
$cybereasonInstalled = Test-Path $cybereasonPath
$output.CybereasonInstalled = $cybereasonInstalled

# Define the list of Cybereason services
$cybereasonServices = @(
    "CybereasonActiveProbe",
    "CybereasonAntiMalware",
    "CybereasonBlocki",
    "CybereasonCRS",
    "CybereasonNnx",
    "CybereasonWscIf"
)

# Check if Cybereason services are running
$runningServices = @()
foreach ($service in $cybereasonServices) {
    try {
        $serviceStatus = Get-Service -Name $service -ErrorAction Stop
        if ($serviceStatus.Status -eq 'Running') {
            $runningServices += $service
        }
    }
    catch {
        # Service not found
        continue
    }
}

# If all services are running, set to true, else false
$allServicesRunning = ($runningServices.Count -eq $cybereasonServices.Count)
$output.CybereasonServicesRunning = $allServicesRunning

# Check if Windows Defender real-time protection is enabled
$defender = Get-MpPreference
$realTimeProtection = ($defender.DisableRealtimeMonitoring -eq $false)
$output.RealTimeProtectionEnabled = $realTimeProtection

# Convert the output to JSON and compress it
return $output | ConvertTo-Json -Compress
