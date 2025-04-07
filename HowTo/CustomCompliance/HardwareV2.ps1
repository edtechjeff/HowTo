$WMI_ComputerSystem = Get-WMIObject -Class Win32_ComputerSystem
$WMI_BIOS = Get-WMIObject -Class Win32_BIOS
$TPM = Get-Tpm

# Get the TPM SpecVersion and extract only the first value (e.g., '2.0')
$TPMVersion = (Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftTpm" -ClassName Win32_Tpm).SpecVersion -split ',' | Select-Object -First 1

$hash = @{
    Manufacturer   = $WMI_ComputerSystem.Manufacturer
    BiosVersion    = $WMI_BIOS.SMBIOSBIOSVersion
    TPMChipPresent = $TPM.TpmPresent
    TPMVersion     = $TPMVersion
}

return $hash | ConvertTo-Json -Compress
