boot.wim

install.wim

Autounattend.xml

sources
    $OEM$
        $1
            Scripts
                Bootstrap.ps1
                InstallRoles.ps1
                ConfigureNetwork.ps1
                EnableWinRM.ps1
                InstallHyperV.ps1
                InstallStorage.ps1
                JoinDomain.ps1
                ConfigureCluster.ps1

            Tools
                BGInfo
                PSTools
                Sysinternals

            Drivers
                VirtIO

        $$
            Setup
                Scripts
                    SetupComplete.cmd

## Inject VirtIO Drivers into boot.wim

```bash
mkdir C:\Mount

dism /Mount-Wim /WimFile:C:\ISO\sources\boot.wim /Index:2 /MountDir:C:\Mount

dism /Image:C:\Mount /Add-Driver /Driver:C:\Drivers /Recurse

dism /Unmount-Wim /MountDir:C:\Mount /Commit
```

## Get List of Indexes in Install WIM

```powershell
Get-WindowsImage -ImagePath "C:\Installs\Windows11\23H2\install.wim"
```

## Export Install.wim [This will export Standard Edition Desktop Version]

```bash
Dism /export-image /sourceimagefile:C:\ISO\sources\install.wim /sourceindex:2 /destinationimagefile:C:\Drivers\Install.wim
```

## Command to Buid ISO

```bash
oscdimg.exe ^
-m ^
-o ^
-u2 ^
-udfver102 ^
-bootdata:2#p0,e,b"C:\ISO\boot\etfsboot.com"#pEF,e,b"C:\ISO\efi\microsoft\boot\efisys.bin" ^
C:\ISO ^
C:\CreatedISO\Server2025-Teaching.iso
```

## Command to copy to ISO to the linux host

```bash
scp Server2025-Teaching.iso jdowns@192.168.0.9:/var/lib/libvirt/images/iso
```

## Install Drivers for boot.wim

Mount-WindowsImage `
    -ImagePath "C:\ISO\sources\boot.wim" `
    -Index 1 `
    -Path "C:\Mount"

Add-WindowsDriver `
    -Path "C:\Mount" `
    -Driver "C:\Drivers" `
    -Recurse

Dismount-WindowsImage `
    -Path "C:\Mount" `
    -Save

## Install Drivers for Install.wim

```powershell
Mount-WindowsImage `
    -ImagePath "C:\ISO\sources\install.wim" `
    -Index 1 `
    -Path "C:\Mount"

Add-WindowsDriver `
    -Path "C:\Mount" `
    -Driver "C:\Drivers" `
    -Recurse

Dismount-WindowsImage `
    -Path "C:\Mount" `
    -Save

Dismount-WindowsImage `
    -Path "C:\Mount" `
    -Discard
```