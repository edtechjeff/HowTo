$PackageName = "Mozilla.Firefox"

#Start Logging
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$($PackageName)_Install.log" -Append

#Trying to install Package with Winget
IF ($PackageName){
    try {
        Write-Host "Installing $($PackageName) via Winget" -ForegroundColor Green

        $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
        $config
        cd $wingetpath

        .\winget.exe install $PackageName --silent --accept-source-agreements --accept-package-agreements
    }
    Catch {
        Throw "Failed to install package $($_)"
    }
}
Else {
    Write-Host "Package $($PackageName) not available" -ForegroundColor Yellow
}
Stop-Transcript
