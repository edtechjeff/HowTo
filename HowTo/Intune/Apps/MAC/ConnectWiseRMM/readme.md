# How to install Connect Wise RMM 

## Some of the scripts can be used to install ConnectWise from a storage account. 
    
- [ConnectWiseRMMV1](ConnectWiseRMMV1.sh) installs from storage account 
- [ConnectWiseRMMV2](ConnectWiseRMMV2.sh) Installs and checks for the existing of the com.ITSPlatform.ITSPlatform program

# Link to another github repo that has some configuration files, original
https://github.com/PsychoData/MacProfiles/blob/main/ConnectWiseControl%20PPPC_WithScreenRecording.mobileconfig


Command on the MAC to get BundleID

mdls -name kMDItemCFBundleIdentifier -r /Applications/ConnectWiseRMM.app

How to get the code requirement
codesign -dr - /Applications/ConnectWiseRMM.app
