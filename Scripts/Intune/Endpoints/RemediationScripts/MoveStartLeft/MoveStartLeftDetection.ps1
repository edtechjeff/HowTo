$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$valueName    = "TaskbarAl"
$expected     = 0

try {
    if (Test-Path $registryPath) {
        $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop

        if ($currentValue.$valueName -eq $expected) {
            Write-Host "Registry key exists and is set correctly (TaskbarAl = 0)."
            exit 0
        }
        else {
            Write-Host "Registry key exists but value is incorrect."
            exit 1
        }
    }
    else {
        Write-Host "Registry path does not exist."
        exit 1
    }
}
catch {
    Write-Host "Registry key does not exist."
    exit 1
}
