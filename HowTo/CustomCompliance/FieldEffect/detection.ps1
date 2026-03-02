$svc = Get-CimInstance Win32_Service |
Where-Object { $_.DisplayName -like "*Covalence*" } |
Select-Object -First 1

$result = @{
  CovalenceServiceFound   = [bool]$svc
  CovalenceServiceRunning = ($svc -and $svc.State -eq "Running")
  CovalenceServiceName    = ($svc.Name)
  CovalenceDisplayName    = ($svc.DisplayName)
}

$result | ConvertTo-Json -Compress