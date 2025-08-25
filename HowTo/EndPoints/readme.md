# Random Information

## Search for file and display path location of the file
```powershell
powershell -command "Get-ChildItem -Path C:\ -Recurse -Filter server2022.iso -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"
```
