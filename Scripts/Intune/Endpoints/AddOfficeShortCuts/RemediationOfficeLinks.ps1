$shortcuts = @(
    @{ Name = "Word"; Path = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" },
    @{ Name = "Excel"; Path = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE" },
    @{ Name = "PowerPoint"; Path = "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" },
    @{ Name = "Publisher"; Path = "C:\Program Files\Microsoft Office\root\Office16\MSPUB.EXE" }
)

$desktopPath = "C:\Users\Public\Desktop"
$missing = $false

foreach ($shortcut in $shortcuts) {
    $shortcutPath = "$desktopPath\$($shortcut.Name).lnk"

    if (-Not (Test-Path $shortcutPath)) {
        Write-Host "Creating shortcut: $($shortcut.Name)"
        $shell = New-Object -ComObject WScript.Shell
        $shortcutFile = $shell.CreateShortcut($shortcutPath)
        $shortcutFile.TargetPath = $shortcut.Path
        $shortcutFile.Save()
        $missing = $true
    }
}

if (-Not $missing) {
    Write-Host "All shortcuts already exist."
} else {
    Write-Host "Missing shortcuts have been created."
}
