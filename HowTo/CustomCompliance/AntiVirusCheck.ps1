# Get the Defender status values
$mpStatus = Get-MpComputerStatus
$RTPEnabled = $mpStatus.RealTimeProtectionEnabled
$AMServiceEnabled = $mpStatus.AMServiceEnabled
$AntiSpyware = $mpStatus.AntispywareEnabled
$AntiVirus = $mpStatus.AntivirusEnabled

# Build the output hashtable
$output = @{
    RTPEnabled      = $RTPEnabled
    AMServiceEnabled = $AMServiceEnabled
    AntiSpyware     = $AntiSpyware
    AntiVirus       = $AntiVirus
}

# Convert to compressed JSON
return $output | ConvertTo-Json -Compress