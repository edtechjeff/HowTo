$csvPath = "d:\scripts\Perms.csv"
$logPath = "d:\scripts\Perms.log"
$dryRun = $true  # <<< Set this to $false to actually apply permissions

# Clear log file at the start
"" | Out-File -FilePath $logPath

function Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append
    Write-Output $message
}

# Check if CSV exists
if (!(Test-Path $csvPath)) {
    Log "Error: CSV file not found at $csvPath"
    exit 1
}

# Import CSV
$permissionsList = Import-Csv -Path $csvPath

foreach ($entry in $permissionsList) {
    $folderPath = $entry.Path
    $group = $entry.Group
    $permissions = $entry.Permissions
    $disableInheritance = $entry.DisableInheritance -as [bool]

    # Validate folder path
    if ([string]::IsNullOrWhiteSpace($folderPath)) {
        Log "Skipping: Empty folder path"
        continue
    }

    if (!(Test-Path $folderPath)) {
        Log "Skipping: Folder does not exist - $folderPath"
        continue
    }

    try {
        # Parse permissions (e.g., "Modify", "ReadAndExecute", etc.)
        $rights = [System.Enum]::Parse([System.Security.AccessControl.FileSystemRights], $permissions, $true)

        # Get current ACL
        $acl = Get-Acl -Path $folderPath

        # Handle inheritance setting
        if ($disableInheritance) {
            if ($dryRun) {
                Log "DryRun: Would disable inheritance (keep inherited) on $folderPath"
            } else {
                $acl.SetAccessRuleProtection($true, $true)
                Log "Inheritance disabled (kept inherited) on $folderPath"
            }
        } else {
            if ($dryRun) {
                Log "DryRun: Would enable inheritance on $folderPath"
            } else {
                $acl.SetAccessRuleProtection($false, $true)
                Log "Inheritance enabled on $folderPath"
            }
        }

        # Create access rule (default to Allow)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, $rights, "None", "None", "Allow")

        if ($dryRun) {
            Log "DryRun: Would apply '$permissions' permission to '$folderPath' for '$group'"
        } else {
            $acl.SetAccessRule($rule)
            Set-Acl -Path $folderPath -AclObject $acl
            Log "Applied '$permissions' permission to '$folderPath' for '$group'"
        }
    } catch {
    Log "Error processing path '$folderPath': $($_.Exception.Message)"
}
}
