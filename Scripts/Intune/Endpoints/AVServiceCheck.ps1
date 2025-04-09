# This script is used to check the status of Windows Defender on a system.
# It checks if the Defender services are running and if real-time protection is enabled.
(Get-MpComputerStatus).AMServiceEnabled
(Get-MpComputerStatus).AntispywareEnabled
(Get-MpComputerStatus).AntivirusEnabled
(Get-MpComputerStatus).RealTimeProtectionEnabled