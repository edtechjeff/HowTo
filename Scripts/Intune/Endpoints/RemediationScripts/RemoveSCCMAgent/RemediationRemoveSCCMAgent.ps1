$regPath = "HKLM:\SOFTWARE\Microsoft\CCM"

if (Test-Path $regPath) {
    Write-Host "SCCM agent detected. Proceeding with removal..."

    # Uninstall SCCM Agent
    Start-Process -FilePath "C:\Windows\ccmsetup\ccmsetup.exe" -ArgumentList "/Uninstall"
    Start-Sleep -Seconds 60
    Wait-Process -Name "ccmsetup" -ErrorAction SilentlyContinue

    # Take ownership of CCM folder
    $folderPath = "C:\Windows\CCM"
    if (Test-Path $folderPath) {
        $user = "BUILTIN\\Administrators"
        $acl = Get-Acl $folderPath
        $account = New-Object System.Security.Principal.NTAccount($user)
        $acl.SetOwner($account)
        Set-Acl $folderPath $acl

        Get-ChildItem -Path $folderPath -Recurse -Force | ForEach-Object {
            try {
                $acl = Get-Acl $_.FullName
                $acl.SetOwner($account)
                Set-Acl $_.FullName $acl
            } catch {
                Write-Warning "Failed to set owner on $($_.FullName): $_"
            }
        }
    }

    # Remove registry keys
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCM -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\SMS -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\DeviceManageabilityCSP -Recurse -Force -ErrorAction SilentlyContinue

    # Remove folders and files
    Remove-Item -Path C:\Windows\CCM -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\CCMCache -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path C:\Windows\SMSCFG.ini -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\sms*.mif" -Force -ErrorAction SilentlyContinue

    Write-Host "SCCM agent removal completed."
} else {
    Write-Host "SCCM agent not found. Nothing to remediate."
}