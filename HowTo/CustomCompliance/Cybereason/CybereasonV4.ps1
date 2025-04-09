# Initialize output hashtable
$output = @{}

# Check if Cybereason is installed
$cybereasonPath = "C:\Program Files\Cybereason ActiveProbe"
$cybereasonInstalled = Test-Path $cybereasonPath
$output.CybereasonInstalled = $cybereasonInstalled

# Define the list of Cybereason services and the ones that can be manual
$cybereasonServices = @(
    "CybereasonActiveProbe",
    "CybereasonAntiMalware",
    "CybereasonBlocki",
    "CybereasonCRS",
    "CybereasonNnx",
    "CybereasonWscIf",
    "CybereasonTI"
)

$manualOK = @("CybereasonCRS", "CybereasonNnx", "CybereasonTI")

$serviceIssues = $false
foreach ($serviceName in $cybereasonServices) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        $startupType = (Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'").StartMode

        if ($startupType -eq "Disabled") {
            $serviceIssues = $true
            break
        }

        if ($manualOK -contains $serviceName) {
            # These can be Manual and not running
            if ($startupType -ne "Manual" -and $startupType -ne "Auto") {
                $serviceIssues = $true
                break
            }
        } else {
            # Must be running and not disabled
            if ($service.Status -ne 'Running') {
                $serviceIssues = $true
                break
            }
        }
    } catch {
        $serviceIssues = $true
        break
    }
}

$output.CybereasonServicesHealthy = -not $serviceIssues
$output.CybereasonServiceIssues = $serviceIssues

# Convert the output to JSON and compress it
return $output | ConvertTo-Json -Compress
