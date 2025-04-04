$csvPath = "D:\Scripts\Perms.csv"

if (!(Test-Path $csvPath)) {
    Write-Output "Error: CSV file not found at $csvPath"
    exit
}

$permissionsList = Import-Csv -Path $csvPath

foreach ($entry in $permissionsList) {
    $folderPath = $entry.Path
    $group = $entry.Group
    $permissions = $entry.Permissions

    # Validate folderPath
    if ([string]::IsNullOrWhiteSpace($folderPath)) {
        Write-Output "Skipping: Empty folder path"
        continue
    }

    if (!(Test-Path $folderPath)) {
        Write-Output "Skipping: Folder does not exist - $folderPath"
        continue
    }

    try {
        # Validate and parse permissions correctly
        $rights = [System.Enum]::Parse([System.Security.AccessControl.FileSystemRights], $permissions, $true)

        # Get the current ACL
        $acl = Get-Acl -Path $folderPath

        # Create a new FileSystemAccessRule
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, $rights, "ContainerInherit, ObjectInherit", "None", "Allow")

        # Add the rule to the ACL
        $acl.SetAccessRule($rule)

        # **Do NOT modify inheritance settings**

        # Apply the ACL back to the folder
        Set-Acl -Path $folderPath -AclObject $acl

        Write-Output "Applied permissions to $folderPath for $group with $permissions (Inheritance unchanged)"
    } catch {
        Write-Output ("Error processing " + $folderPath + ": " + $_.Exception.Message)
    }
}
