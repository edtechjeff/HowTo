$services = @(
    "CybereasonActiveProbe",
    "CybereasonAntiMalware",
    "CybereasonBlocki",
    "CybereasonCRS",
    "CybereasonNnx",
    "CybereasonWscIf"
)

foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -eq $null) {
        Write-Host "$svc not found"
        continue
    }

    if ($service.Status -ne "Running") {
        Write-Host "Starting $svc"
        Start-Service -Name $svc
    } else {
        Write-Host "$svc is already running"
    }
}
