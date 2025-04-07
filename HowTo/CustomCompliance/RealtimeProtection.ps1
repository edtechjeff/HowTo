# Get the RealTimeProtectionEnabled status
$RTPEnabled = (Get-MpComputerStatus).RealTimeProtectionEnabled

# Convert the result to JSON format
return $RTPEnabled | ConvertTo-Json -Compress