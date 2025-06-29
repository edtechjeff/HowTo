$objSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-21-1111111111-2222222222-3333333333-1001")
$objSID.Translate([System.Security.Principal.NTAccount])