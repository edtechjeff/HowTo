# This is used when you have a server that is not activated. You should activate a production server but this is used more for testing. Use at your own risk

- Open cmd with Run as administrator
- CD to the folder path and run execute psexec -i -s cmd.exe
- In the newly open CMD Type services.msc
- This will open services and now you can navigate to Windows License Monitoring Service and disable it
- Restart the VM