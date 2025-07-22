# Path to the source (template) folder with correct permissions
$sourceFolder = "C:\Path\To\TemplateFolder"

# Load ACL from the source folder
$sourceAcl = Get-Acl -Path $sourceFolder

# Path to your CSV file with folders to apply permissions to
$csvPath = "C:\Path\To\folders.csv"

# Import folders from CSV
$folders = Import-Csv -Path $csvPath

foreach ($folder in $folders) {
    # Ensure the property FullName exists and is not null or empty
    if ($folder.FullName -and (Test-Path -Path $folder.FullName)) {
        try {
            # Apply ACL
            Set-Acl -Path $folder.FullName -AclObject $sourceAcl
            Write-Host "Permissions applied to $($folder.FullName)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to apply permissions to $($folder.FullName): $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Folder does not exist or is invalid: $($folder.FullName)"
    }
}
