$csvPath = "F:\scripts\cleaned_Information_documenation_Folder.csv"
$logPath = "F:\scripts\documentation_PermissionScriptLog.txt"

# Clear or create the log
"" | Out-File -FilePath $logPath

# Timestamped logging helper
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append
    Write-Host "$timestamp - $message"
}

if (!(Test-Path $csvPath)) {
    Write-Log "Error: CSV file not found at $csvPath"
    exit
}

$entries = Import-Csv -Path $csvPath

foreach ($entry in $entries) {
    $folder = $entry.Path
    $group = $entry.group
    $permissions = $entry.permissions
    $inherit = $entry.inherit

    if ([string]::IsNullOrWhiteSpace($folder)) {
        Write-Log "Skipping empty folder path"
        continue
    }

    if (!(Test-Path $folder)) {
        Write-Log "Skipping: Folder does not exist - $folder"
        continue
    }

    Write-Log "Processing folder: $folder"
    Write-Log "Attempting to resolve group: $group"

    try {
        $ntAccount = New-Object System.Security.Principal.NTAccount($group)
        $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
        Write-Log "Group resolved successfully: $group -> $sid"
    } catch {
        Write-Log "Failed to resolve group: $group. Skipping."
        continue
    }

    # Convert PowerShell-style permission list to icacls format
    switch -Wildcard ($permissions) {
        "*Modify*"         { $icaclsPerms = "M" }
        "*ReadAndExecute*" { $icaclsPerms = "RX" }
        "*FullControl*"    { $icaclsPerms = "F" }
        default {
            Write-Log "Unsupported permission format: $permissions for $group"
            continue
        }

    }

    # Set inheritance based on CSV
    if ($inherit -eq "FALSE") {
        $inheritCmd = "icacls `"$folder`" /inheritance:r"
        Write-Log "Disabling inheritance: $inheritCmd"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $inheritCmd" -NoNewWindow -Wait
    } elseif ($inherit -eq "TRUE") {
        $inheritCmd = "icacls `"$folder`" /inheritance:e"
        Write-Log "Enabling inheritance: $inheritCmd"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $inheritCmd" -NoNewWindow -Wait
    }

    # Construct icacls command
    $icaclsCmd = "icacls `"$folder`" /grant `"$group`":$icaclsPerms"

    Write-Log "Applying icacls command: $icaclsCmd"

    try {
        $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $icaclsCmd" -NoNewWindow -Wait -PassThru


        if ($proc.ExitCode -eq 0) {
            Write-Log "Successfully applied permissions to $folder for $group"
        } else {
            Write-Log "Failed to apply permissions. Exit code: $($proc.ExitCode)"
        }
    } catch {
        Write-Log "Exception when applying permissions: $_"
    }
}
