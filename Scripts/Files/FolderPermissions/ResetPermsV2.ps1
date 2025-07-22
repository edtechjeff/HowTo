$folderPath = "F:\Information\Records"
$logRoot = "E:\ScriptMay272025\Logs"

# Create log folder if it doesn't exist
if (!(Test-Path -Path $logRoot)) {
    New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
}

# Build dynamic log file name
$folderName = Split-Path $folderPath -Leaf
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$logFile = Join-Path $logRoot "$folderName`_$timestamp.log"

function Write-Log {
    param (
        [string]$message
    )
    $message | Tee-Object -FilePath $logFile -Append
}

if (!(Test-Path $folderPath)) {
    Write-Log "❌ Folder not found: $folderPath"
    exit
}

try {
    Write-Log "🔄 Resetting permissions on $folderPath and all sub-items"
    icacls $folderPath /reset /C /T /Q | ForEach-Object { Write-Log $_ }

    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    Write-Log "🔒 Inheritance disabled and inherited permissions removed"

    $defaultRules = @(
        @{ Group = "BUILTIN\Administrators"; Rights = "FullControl" },
        @{ Group = "NT AUTHORITY\SYSTEM"; Rights = "FullControl" },
        @{ Group = "addman\sec_file_admin"; Rights = "Modify" }
    )

    foreach ($rule in $defaultRules) {
        try {
            $ntAccount = New-Object System.Security.Principal.NTAccount($rule.Group)
            $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
            $rights = [System.Security.AccessControl.FileSystemRights]::$($rule.Rights)
            $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit, [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
            $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
            $accessType = [System.Security.AccessControl.AccessControlType]::Allow

            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $sid,
                $rights,
                $inheritanceFlags,
                $propagationFlags,
                $accessType
            )

            $acl.AddAccessRule($accessRule)
            Write-Log "✅ Added $($rule.Rights) for $($rule.Group)"
        } catch {
            Write-Log "❌ Failed to add rule for $($rule.Group): $($_.Exception.Message)"
        }
    }

    Set-Acl -Path $folderPath -AclObject $acl
    Write-Log "✅ Permissions applied to $folderPath"

    Write-Log "🔁 Applying custom ACL to all subfolders"
    Get-ChildItem -Path $folderPath -Recurse -Directory -Force | ForEach-Object {
        try {
            Set-Acl -Path $_.FullName -AclObject $acl
            Write-Log "✅ Applied ACL to: $($_.FullName)"
        } catch {
            Write-Log "❌ Failed to apply ACL to $($_.FullName): $($_.Exception.Message)"
        }
    }

} catch {
    Write-Log "❌ Error applying permissions: $($_.Exception.Message)"
}
