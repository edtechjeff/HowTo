# This script renames a computer in an Intune managed environment.
# Ensure you have the necessary permissions to rename the computer and that the device is compliant with Intune policies.
Rename-Computer -ComputerName OLDNAME -NewName NEWNAME -DomainCredential (Get-Credential) -Force -Restart -PassThru