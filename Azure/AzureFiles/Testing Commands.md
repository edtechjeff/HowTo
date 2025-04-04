# Test for DNS Name Resolution
```
Resolve-dnsname privatelink.file.core.windows.net
```

# Test to see if you can gain access to the share
```
test-netconnection -computername privatelink.file.core.windows.net -commonTCPport sMB
```

# Test to see if you can gain access to the share via IP
```
test-netconnection -computername 10.0.1.4 -commonTCPport sMB
```

# Get the target storage account
```
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$StorageAccount | Get-AzStorageAccountKey -ListKerbKey | ft KeyName
```

# List the directory service of the selected service account
```
$StorageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions
```
# List the directory domain information if the storage account has enabled AD Authentication for file shares
```
$StorageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties
```