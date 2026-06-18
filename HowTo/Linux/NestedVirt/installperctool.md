# Download 
https://www.dell.com


## Copy to server
scp PERCCLI*.tar.gz jdowns@192.168.0.9:/tmp

## Extract It
cd /tmp
tar -xzvf PERCCLI*.tar.gz

## Check if there is a directory or not 
ls

## If directory change to that directory
cd PERCCLI

## If not then run the following command using the output of the LS to get full file name
sudo dpkg -i *.deb

## Verify
dpkg -l | grep perccli

## Change to Directory
cd /opt/MegaRAID/perccli

## Run it
sudo ./perccli64 show

## Show Controllers
sudo ./perccli64 show

## Show Controller Information
sudo ./perccli64 /c0 show

## Show Physical Disks
sudo ./perccli64 /c0 /eall /sall show

## Show Virtual Disks
sudo ./perccli64 /c0 /vall show

## Show Raid Health
sudo ./perccli64 /c0 show all

## Show Battery
sudo ./perccli64 /c0 show battery

## Add PERCCLI64 to path
echo 'export PATH=$PATH:/opt/MegaRAID/perccli' >> ~/.bashrc
source ~/.bashrc

## the following command should work after you add the path
sudo perccli64 /c0 /eall /sall show


