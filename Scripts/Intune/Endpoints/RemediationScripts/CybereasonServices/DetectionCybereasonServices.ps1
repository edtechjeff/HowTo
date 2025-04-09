$services = @(
    "CybereasonActiveProbe",
    "CybereasonAntiMalware",
    "CybereasonBlocki",
    "CybereasonCRS",
    "CybereasonNnx",
    "CybereasonWscIf"
)

$stoppedServices = @()

foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -eq $null) {
        $stoppedServices += "$svc (not found)"
        continue
    }

    if ($service.Status -ne "Running") {
        $stoppedServices += "$svc (Status: $($service.Status))"
    }
}

if ($stoppedServices.Count -gt 0) {
    Write-Host "The following Cybereason services are not running:"
    $stoppedServices | ForEach-Object { Write-Host $_ }
    exit 1
} else {
    Write-Host "All Cybereason services are running."
    exit 0
}
