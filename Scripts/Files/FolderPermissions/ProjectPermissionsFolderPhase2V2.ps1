$csvPath = "d:\scripts\Perms.csv"
$logPath = "d:\scripts\Perms.log"
$dryRun = $true  # <<< Set this to $false to actually apply permissions

function Write-Log {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
    Add-Content -Path $logPath -Value $logMessage
}

if (!(Test-Path $csvPath)) {
    Write-Log "Error: CSV file not found at $csvPath"
    exit
}

Write-Log "Script started. Dry run mode: $dryRun"

$permissionsList = Import-Csv -Path $csvPath

foreach ($entry in $permissionsList) {
    $folderPath = $entry.Path
    $group = $entry.Group
    $permissions = $entry.Permissions
    $disableInheritance = $entry.DisableInheritance -as [bool]  # Convert CSV value to boolean

    if ([string]::IsNullOrWhiteSpace($folderPath)) {
        Write-Log "Skipping: Empty folder path"
        continue
    }

    if (!(Test-Path $folderPath)) {
        Write-Log "Skipping: Folder does not exist - $folderPath"
        continue
    }

    try {
        $rights = [System.Enum]::Parse([System.Security.AccessControl.FileSystemRights], $permissions, $true)
        $acl = Get-Acl -Path $folderPath

        if ($disableInheritance) {
            $acl.SetAccessRuleProtection($true, $true)  # Disable inheritance but keep inherited permissions
            Write-Log "Inheritance Disabled (kept inherited permissions) for $folderPath"
        } else {
            Write-Log "Inheritance Kept for $folderPath"
        }

        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, $rights, "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)

        if ($dryRun) {
            Write-Log "[DRY RUN] Would apply permissions to '$folderPath' for group '$group' with rights '$permissions' (DisableInheritance: $disableInheritance)"
        } else {
            Set-Acl -Path $folderPath -AclObject $acl
            Write-Log "Applied permissions to '$folderPath' for group '$group' with rights '$permissions' (DisableInheritance: $disableInheritance)"
        }
    } catch {
        Write-Log "Error processing '$folderPath': $($_.Exception.Message)"
    }
}

Write-Log "Script finished."
