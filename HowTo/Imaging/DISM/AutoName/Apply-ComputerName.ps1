$LogPath  = "C:\Windows\Setup\Scripts\Apply-ComputerName.log"
$NameFile = "C:\Windows\Setup\Scripts\ComputerName.txt"

Start-Transcript -Path $LogPath -Append

try {
    Write-Host "Starting Apply-ComputerName.ps1"

    if (-not (Test-Path $NameFile)) {
        throw "ComputerName.txt was not found at $NameFile"
    }

    $NewName = (Get-Content -Path $NameFile -ErrorAction Stop | Select-Object -First 1).Trim()

    if ([string]::IsNullOrWhiteSpace($NewName)) {
        throw "ComputerName.txt exists but contains no valid computer name."
    }

    $CurrentName = $env:COMPUTERNAME
    Write-Host "Current computer name: $CurrentName"
    Write-Host "Desired computer name: $NewName"

    if ($CurrentName -ieq $NewName) {
        Write-Host "Computer name already matches desired name. No rename needed."
    }
    else {
        Rename-Computer -NewName $NewName -Force -ErrorAction Stop
        Write-Host "Rename successful. Restarting computer..."
        Stop-Transcript
        Restart-Computer -Force
        exit
    }

    Write-Host "No restart needed."
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
}
finally {
    try { Stop-Transcript } catch {}
}