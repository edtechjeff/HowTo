$mountPath = "E:\Images\Mount"

# remove provisioned apps first
# ...your DISM removal section here...

# apply offline registry setting before commit
reg load HKLM\OFFLINE "$mountPath\Windows\System32\Config\SOFTWARE"

New-Item -Path "HKLM:\OFFLINE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
New-ItemProperty -Path "HKLM:\OFFLINE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableWindowsConsumerFeatures" -Value 1 -PropertyType DWord -Force

reg unload HKLM\OFFLINE

# then commit the image
dism /Unmount-Image /MountDir:$mountPath /Commit