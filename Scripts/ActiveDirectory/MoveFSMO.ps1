Move-ADDirectoryServerOperationMasterRole -Identity "NEWDC" `
  -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster `
  -Confirm:$false