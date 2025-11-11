$folderPath = "C:\ProgramData\BGInfo"
$bginfoExe  = "$folderPath\bginfo.exe"
$bgiConfig  = "$folderPath\StaffWAW.bgi"

# Ensure folder exists
if (!(Test-Path $folderPath)) {
    Write-Host "Creating BGInfo folder..."
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
}

# Optionally, recopy files from a known location if you want self-healing
# Copy-Item -Path "\\server\share\BGInfo\*" -Destination $folderPath -Recurse -Force

# Define scheduled task
$taskName = "BGInfo"
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating scheduled task for BGInfo..."
    $action = New-ScheduledTaskAction -Execute $bginfoExe -Argument "`"$bgiConfig`" /silent /timer:0"
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Run BGInfo at logon" -Force
} else {
    Write-Host "Scheduled task already exists."
}
