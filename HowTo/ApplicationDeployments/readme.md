# Setup to pull M365 offline installer
## Sameple config-packager.xml Document
***Note: File needs to be called config-packager.xml***

# Download the following tool
https://www.microsoft.com/en-in/download/details.aspx?id=49117&msockid=08877f7e954f67402d7e6b00942d666b

```
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="SkypeForBusiness" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
```

## On Admin station run the following command
```
setup.exe /packager config-packager.xml C:\OfficePackage
```

## This creates self-ccontained folder
```
C:\OfficePackage\
   ├─ setup.exe
   ├─ config-packager.xml
   └─ Office\Data\...
```

# Copy the whole folder to the machine you want to deploy
```
C:\Windows\Setup\Scripts\OfficePackage\
```

## Call the package via the following
```
REM === Install Microsoft 365 Apps for Enterprise (Offline Packager) ===
start /wait C:\Windows\Setup\Scripts\OfficePackage\setup.exe /configure C:\Windows\Setup\Scripts\OfficePackage\config-packager.xml
```
