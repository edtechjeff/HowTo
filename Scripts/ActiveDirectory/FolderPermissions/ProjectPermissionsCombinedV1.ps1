$csvPath = "d:\scripts\Perms.csv"
$logFolder = "d:\scripts\Logs"
if (!(Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}
$logFile = Join-Path $logFolder ("PermissionsLog_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - $message"
    Write-Output $line
    Add-Content -Path $logFile -Value $line
}

if (!(Test-Path $csvPath)) {
    Write-Log "ERROR: CSV file not found at $csvPath"
    exit
}

$permissionsList = Import-Csv -Path $csvPath

foreach ($entry in $permissionsList) {
    $folderPath = $entry.Path
    $group = $entry.Group
    $permissions = $entry.Permissions
    $disableInheritance = $entry.DisableInheritance -as [bool]

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
            $acl.SetAccessRuleProtection($true, $true)
            Write-Log "Inheritance Disabled (kept inherited permissions) for $folderPath"
        } else {
            $acl.SetAccessRuleProtection($false, $true)
            Write-Log "Inheritance Enabled for $folderPath"
        }

        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $group,
            $rights,
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )

        $acl.SetAccessRule($rule)
        Set-Acl -Path $folderPath -AclObject $acl

        Write-Log "Applied permissions to $folderPath for $group with $permissions (DisableInheritance: $disableInheritance)"
    }
    catch {
        Write-Log "ERROR processing $folderPath: $($_.Exception.Message)"
    }
}
