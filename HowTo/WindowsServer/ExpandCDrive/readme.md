---
title: "Basic Intune Setup"
author: "Jeff Downs"
date: \today
toc: true
toc-depth: 3
---

# Expand C: Drive on a VM When Recovery Partition Blocks Extension

## Overview

When you expand a VHDX in Hyper-V, the additional disk space is added to the **end of the disk**.

If the disk layout is:

```
[ EFI ] [ MSR ] [ C: ] [ Recovery ] [ Unallocated Space ]
```

Windows cannot extend the C: drive because the **Recovery partition is between C: and the new unallocated space**.

This document outlines the supported method to:

1. Disable WinRE
2. Remove the Recovery partition
3. Extend C:
4. Recreate the Recovery partition (optional but recommended)

---

## Requirements

- Administrative PowerShell
- VM expanded at Hyper-V level
- Snapshot/Checkpoint recommended before partition modification

---

# Procedure

---

## Step 1 – Verify Current Recovery Configuration

```powershell
reagentc /info
```

Confirm WinRE is enabled and note its location.

---

## Step 2 – Disable Windows Recovery Environment

```powershell
reagentc /disable
```

Verify:

```powershell
reagentc /info
```

Status should show **Disabled**.

---

## Step 3 – Identify and Remove the Recovery Partition

Open elevated PowerShell:

```powershell
diskpart
```

List disks:

```powershell
list disk
select disk 0
list partition
```

Identify the Recovery partition (typically 500MB–900MB).

Select and delete it:

```powershell
select partition X
delete partition override
exit
```

After deletion, layout should look like:

```
[ EFI ] [ MSR ] [ C: ] [ Unallocated Space ]
```

---

## Step 4 – Extend the C: Drive

Option 1 – Using DiskPart:

```powershell
diskpart
select volume C
extend
exit
```

Option 2 – Using GUI:

1. Open Disk Management
2. Right-click C:
3. Select **Extend Volume**
4. Accept defaults

---

## Step 5 – (Optional) Recreate Recovery Partition

### Shrink C: by 1GB

```powershell
diskpart
select volume C
shrink desired=1024
exit
```

### Create New Recovery Partition

```powershell
diskpart
create partition primary size=1024
format quick fs=ntfs label="Recovery"
set id=27
exit
```

### Re-enable WinRE

```powershell
reagentc /enable
reagentc /info
```

Status should show **Enabled**.

---

# Verification

Confirm final layout:

```powershell
Get-Partition
Get-Volume
```

Expected layout:

```
[ EFI ] [ MSR ] [ C: (Expanded) ] [ Recovery ]
```

---

# Important Notes

- Do NOT delete the EFI partition.
- Do NOT convert to Dynamic disk.
- Avoid third-party partition tools in production.
- Always checkpoint production VMs before disk changes.

---

# Hyper-V Considerations

- VM can be online for VHDX expansion (if supported), but partition changes require guest OS modification.
- If using Cluster Shared Volumes (CSV), expansion is performed on the VHDX, but partition work is inside the guest.
- Ensure backups are current before modifying domain controllers.

---

# Summary

The issue occurs because Windows requires unallocated space directly after the C: partition to extend it. Removing the Recovery partition allows extension and can be safely recreated afterward.
