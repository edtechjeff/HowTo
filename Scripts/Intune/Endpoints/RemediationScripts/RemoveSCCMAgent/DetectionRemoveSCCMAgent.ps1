$regPath = "HKLM:\SOFTWARE\Microsoft\CCM"

if (Test-Path $regPath) {
    Write-Host "SCCM agent is present."
    exit 1  # Detected – remediation required
} else {
    Write-Host "SCCM agent is not present."
    exit 0  # Not detected – no action needed
}
