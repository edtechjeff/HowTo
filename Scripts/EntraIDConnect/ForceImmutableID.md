# Used to Force Immutable ID

## Retrieve the GUID for user 'johndoe'
```powershell
$user = Get-ADUser -Identity "johndoe" -Properties objectGUID
$user.objectGUID
```

## Retrieve the GUID for All Users
```powershell
Get-ADUser -Filter * -Properties objectGUID, UserPrincipalName | Select-Object UserPrincipalName, @{Name="GUID";Expression={[System.Guid]::New($_.objectGUID)}}
```

## Convert to base 64 String
```powershell
[Convert]::ToBase64String([guid]::New("YOURGUIDID").ToByteArray())
```

## Run Commands to get MSOnline Running
```powershell
Install-Module MSOnline
Import-Module MSOnline
Connect-MsolService
```

## Check to see if the user has an ImmutableID
```powershell
Get-Msoluser -UserPrincipalName johndoe@edtechjeff.com | Select-Object ImmutableId
```

## Set ImmutableID
```powershell
Set-MsolUser -UserPrincipalName johndoe@edtechjeff.com -ImmutableId EpoakjdlfkajdlkfjiJQ==
```

## Disconnect Graph
```powershell
disconnect-mggraph
```

