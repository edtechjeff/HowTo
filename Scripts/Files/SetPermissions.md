# Setting Permissions with `icacls`

This document explains how to use the `icacls` command to set permissions on files and folders, along with a breakdown of the command's flags and a test example.

---

## Script to Set Permissions

```cmd
icacls "Z:\Shares\Accounts" /grant "AccountsTeam:(OI)(CI)(RX,W)" /T
icacls "Z:\Shares\Accounts" /deny "AccountsTeam:(OI)(CI)(D,DC)" /T
```

### Explanation of the Script

1. **Grant Permissions**  
    The first command grants the `AccountsTeam` group the following permissions on the `Z:\Shares\Accounts` folder and its contents:
    - `(OI)` Object Inherit — applies to files inside.
    - `(CI)` Container Inherit — applies to subfolders.
    - `(RX)` Read & execute.
    - `(W)` Write.
    - `/T` Apply recursively through subfolders and files.

2. **Deny Permissions**  
    The second command denies the `AccountsTeam` group the following permissions:
    - `(D)` Delete.
    - `(DC)` Delete child objects (subfolders/files).
    - `/T` Apply recursively through subfolders and files.

---

## Flag Breakdown

| Flag | Meaning                                   |
|------|-------------------------------------------|
| (OI) | Object Inherit — applies to files inside  |
| (CI) | Container Inherit — applies to subfolders |
| (RX) | Read & execute                            |
| (W)  | Write                                     |
| (D)  | Delete                                    |
| (DC) | Delete child objects (subfolders/files)   |
| /T   | Apply recursively through subfolders/files|

---

## Testing on a Single File

To test the permissions on a single file, use the following commands:

```cmd
icacls "Z:\Shares\Accounts\testfile.txt" /grant "AccountsTeam:(RX,W)"
```
```
icacls "Z:\Shares\Accounts\testfile.txt" /deny "AccountsTeam:(D)"
```

### Explanation of the Test Commands

1. **Grant Permissions**  
    Grants the `AccountsTeam` group the following permissions on `testfile.txt`:
    - `(RX)` Read & execute.
    - `(W)` Write.

2. **Deny Permissions**  
    Denies the `AccountsTeam` group the following permission:
    - `(D)` Delete.

---

By using the `icacls` command, you can effectively manage permissions for files and folders in a Windows environment.  