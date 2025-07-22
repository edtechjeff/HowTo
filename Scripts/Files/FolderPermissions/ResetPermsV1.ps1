$folderPath = "F:\Information\Records"

if (!(Test-Path $folderPath)) {
    Write-Output "❌ Folder not found: $folderPath"
    exit
}

try {
    # Step 1: Reset permissions recursively
    Write-Output "🔄 Resetting permissions on $folderPath and all sub-items"
    icacls $folderPath /reset /C /T /Q

    # Step 2: Create a new ACL object
    $acl = New-Object System.Security.AccessControl.DirectorySecurity

    # Step 3: Disable inheritance and remove inherited permissions
    $acl.SetAccessRuleProtection($true, $false)
    Write-Output "🔒 Inheritance disabled and inherited permissions removed"

    # Step 4: Define default access rules
    $defaultRules = @(
        @{ Group = "BUILTIN\Administrators"; Rights = "FullControl" },
        @{ Group = "NT AUTHORITY\SYSTEM"; Rights = "FullControl" },
        @{ Group = "BUILTIN\Users"; Rights = "ReadAndExecute" },
        @{ Group = "addman\sec_HARb_file_admin"; Rights = "Modify" }
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
            Write-Output "✅ Added $($rule.Rights) for $($rule.Group)"
        } catch {
            Write-Output "❌ Failed to add rule for $($rule.Group): $($_.Exception.Message)"
        }
    }

    # Step 5: Apply ACL to the root folder
    Set-Acl -Path $folderPath -AclObject $acl
    Write-Output "✅ Permissions applied to $folderPath"

    # Step 6: Apply the same ACL to all subfolders
    Write-Output "🔁 Applying custom ACL to all subfolders"
    Get-ChildItem -Path $folderPath -Recurse -Directory -Force | ForEach-Object {
        try {
            Set-Acl -Path $_.FullName -AclObject $acl
            Write-Output "✅ Applied ACL to: $($_.FullName)"
        } catch {
            Write-Output "❌ Failed to apply ACL to $($_.FullName): $($_.Exception.Message)"
        }
    }

} catch {
    Write-Output "❌ Error applying permissions: $($_.Exception.Message)"
}