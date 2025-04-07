$avActive = $false
if(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct){
    $avActive = $true
}

$output = @{ AvActive = $avActive}
return $output | ConvertTo-Json -Compress