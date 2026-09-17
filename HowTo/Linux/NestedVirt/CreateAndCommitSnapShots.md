# KVM / Libvirt VM Snapshots and Committing 

This guide covers creating and managing **external snapshots** for KVM virtual machines using `virsh` and `qcow2` disks.

> **Important:** A snapshot is not a backup. Snapshots are useful for quickly protecting a VM before testing, updates, or configuration changes.

This guide uses a **live snapshot workflow**, meaning the VM can remain running while the snapshot is created and while changes are later committed back to the original disk.

---

# 1. Check the VM and Its Disks

List the virtual machines:

```bash
sudo virsh list --all
```

Check the disks attached to the VM:

```bash
sudo virsh domblklist HV01 --details
```

Example:

```text
Type   Device   Target   Source
---------------------------------------------------------------
file   disk     vda      /var/lib/libvirt/images/HV01.qcow2
file   cdrom    sda      /var/lib/libvirt/images/Server2022.iso
file   cdrom    sdb      /var/lib/libvirt/images/virtio-win.iso
```

In this example:

- `vda` is the actual VM disk.
- `sda` is the Windows installation ISO.
- `sdb` is the VirtIO driver ISO.

Only `vda` needs to be snapshotted.

---

# 2. Check the QCOW2 Disk

If the VM is **shut down**, the disk can be inspected normally:

```bash
sudo qemu-img info /var/lib/libvirt/images/HV01.qcow2
```

If the VM is running, `qemu-img` may report:

```text
Failed to get shared "write" lock
Is another process using the image?
```

This is normal because QEMU has the VM disk open.

For a running VM, use:

```bash
sudo qemu-img info --force-share \
  /var/lib/libvirt/images/HV01.qcow2
```

Verify that the disk reports:

```text
file format: qcow2
corrupt: false
```

> Do not use `qemu-img commit` against an active disk while the VM is running. Use `virsh blockcommit` as described later in this guide.

---

# Creating a Live External Snapshot

The VM can remain **running** while the external snapshot is created.

Explicitly tell libvirt to snapshot `vda` and **not** the CD-ROM devices.

```bash
sudo virsh snapshot-create-as HV01 \
  --name "before-changes" \
  --description "Before configuration changes" \
  --disk-only \
  --atomic \
  --diskspec vda,snapshot=external \
  --diskspec sda,snapshot=no \
  --diskspec sdb,snapshot=no
```

This creates an external QCOW2 overlay.

Conceptually:

```text
HV01 VM
   │
   ▼
Snapshot Overlay        ← New changes are written here
   │
   ▼
HV01.qcow2              ← Original/base disk
```

The original `HV01.qcow2` becomes the backing image.

All new changes made by the VM are written to the external overlay.

---

# Verify the Snapshot

List snapshots:

```bash
sudo virsh snapshot-list HV01
```

Example:

```text
Name             Creation Time               State
-------------------------------------------------------
before-changes   2026-09-17 05:00:00 -0400   disk-snapshot
```

For additional information:

```bash
sudo virsh snapshot-info HV01 before-changes
```

Check which disk the running VM is currently using:

```bash
sudo virsh domblklist HV01 --details
```

Before the snapshot you may have had:

```text
vda   /var/lib/libvirt/images/HV01.qcow2
```

After the external snapshot, `vda` should point to the new overlay.

For example:

```text
vda   /var/lib/libvirt/images/HV01.before-changes
```

This is expected.

The disk chain is now:

```text
HV01 VM
   │
   ▼
HV01.before-changes     ← ACTIVE disk
   │
   ▼
HV01.qcow2              ← BACKING/base disk
```

---

# Understanding the External Snapshot

After creating the snapshot, the VM configuration may contain something similar to:

```xml
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2'/>
  <source file='/var/lib/libvirt/images/HV01.before-changes'/>

  <backingStore type='file'>
    <format type='qcow2'/>
    <source file='/var/lib/libvirt/images/HV01.qcow2'/>
  </backingStore>

  <target dev='vda' bus='virtio'/>
</disk>
```

This is **normal**.

It means:

```text
HV01.before-changes
        │
        │ backingStore
        ▼
HV01.qcow2
```

Do **not** manually remove the `<backingStore>` section while the overlay is active.

---

# Keeping the Changes and Removing the Snapshot

If testing is successful and you want to **keep all changes made since the snapshot**, the changes can be merged into the original disk while the VM remains running.

## Step 1 — Verify the Active Disk

```bash
sudo virsh domblklist HV01 --details
```

You should see the overlay as `vda`:

```text
file   disk   vda   /var/lib/libvirt/images/HV01.before-changes
```

---

## Step 2 — Commit and Pivot

Run:

```bash
sudo virsh blockcommit HV01 vda \
  --active \
  --pivot \
  --verbose
```

You should see progress similar to:

```text
Block commit: [100.00 %]
Successfully pivoted
```

The `--active` option tells libvirt that the active overlay is being committed.

The `--pivot` option tells libvirt to switch the running VM back to the original/base disk after the merge completes.

Conceptually:

```text
BEFORE

HV01 VM
   │
   ▼
HV01.before-changes
   │
   ▼
HV01.qcow2


       BLOCKCOMMIT
            +
          PIVOT
            │
            ▼


AFTER

HV01 VM
   │
   ▼
HV01.qcow2
```

The changes from the overlay have now been merged into `HV01.qcow2`.

The VM continues running during this process.

---

## Step 3 — Verify the Pivot

This is an **important verification step**.

Run:

```bash
sudo virsh domblklist HV01 --details
```

You want to see:

```text
file   disk   vda   /var/lib/libvirt/images/HV01.qcow2
```

You should **no longer** see:

```text
HV01.before-changes
```

as the active `vda` disk.

If `HV01.before-changes` is still shown as the active disk, **do not delete it**.

---

## Step 4 — Check Snapshot Metadata

Run:

```bash
sudo virsh snapshot-list HV01
```

Depending on the libvirt operation and snapshot state, the snapshot metadata may already be gone.

If the list is empty:

```text
Name   Creation Time   State
-------------------------------
```

there is nothing else to remove.

If `before-changes` is still listed, remove **only the metadata**:

```bash
sudo virsh snapshot-delete HV01 before-changes --metadata
```

Then verify:

```bash
sudo virsh snapshot-list HV01
```

---

## Step 5 — Verify the Overlay Is No Longer in Use

Before deleting the old overlay, check whether anything still has it open:

```bash
sudo lsof /var/lib/libvirt/images/HV01.before-changes
```

If nothing is returned, the file is not currently open by QEMU.

Also verify one more time:

```bash
sudo virsh domblklist HV01 --details
```

Make sure `vda` points to:

```text
/var/lib/libvirt/images/HV01.qcow2
```

---

## Step 6 — Delete the Old Overlay

Only after confirming:

- `blockcommit` reported `Successfully pivoted`
- `vda` points to `HV01.qcow2`
- the VM is operating correctly
- the old overlay is no longer in use

delete the old overlay:

```bash
sudo rm /var/lib/libvirt/images/HV01.before-changes
```

> **Never delete an overlay while `domblklist` still shows it as the active VM disk.**

---

# Important: `qemu-img` Lock Errors

When a VM is running, commands such as:

```bash
sudo qemu-img info /var/lib/libvirt/images/HV01.before-changes
```

may return:

```text
Failed to get shared "write" lock
Is another process using the image?
```

This usually means QEMU is actively using the image.

This is expected.

For an active VM, prefer libvirt commands such as:

```bash
sudo virsh domblklist HV01 --details
```

For inspection only, `qemu-img info` can use:

```bash
sudo qemu-img info --force-share /path/to/image
```

Do not use `qemu-img commit` against an active overlay.

For the live workflow use:

```bash
sudo virsh blockcommit HV01 vda --active --pivot --verbose
```

---

# Important Lesson: Do Not Snapshot ISO Drives

Avoid creating an external snapshot without specifying which disks should participate.

For example:

```bash
sudo virsh snapshot-create-as HV01 \
  --name "before-changes" \
  --disk-only \
  --atomic
```

may cause libvirt to attempt snapshot operations involving CD-ROM devices.

You could end up with an unnecessarily complicated configuration involving:

```text
vda → HV01 snapshot overlay

sda → Server2022 ISO

sdb → VirtIO ISO
```

Always explicitly exclude the CD-ROM devices:

```bash
--diskspec vda,snapshot=external \
--diskspec sda,snapshot=no \
--diskspec sdb,snapshot=no
```

---

# Fixing an ISO/QCOW2 Format Problem

If a previous external snapshot operation accidentally involved CD-ROM drives, you may encounter:

```text
Image is not in qcow2 format
```

This can happen when the VM is pointed back to an `.iso`, but the XML still identifies the device as QCOW2.

Edit the VM:

```bash
sudo virsh edit HV01
```

A normal ISO/CD-ROM should look similar to:

```xml
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/path/to/Server2022.iso'/>
  <target dev='sda' bus='sata'/>
  <readonly/>
</disk>
```

The important part is:

```xml
type='raw'
```

An ISO is a raw image, not QCOW2.

The VM's main virtual disk should still use:

```xml
<driver name='qemu' type='qcow2'/>
```

---

# Useful Snapshot Commands

### List snapshots

```bash
sudo virsh snapshot-list HV01
```

### Get snapshot details

```bash
sudo virsh snapshot-info HV01 before-changes
```

### View snapshot XML

```bash
sudo virsh snapshot-dumpxml HV01 before-changes
```

### Check active VM disks

```bash
sudo virsh domblklist HV01 --details
```

### Check VM state

```bash
sudo virsh domstate HV01
```

### Inspect a QCOW2 image while the VM is stopped

```bash
sudo qemu-img info /path/to/image.qcow2
```

### Inspect an image while it may be in use

```bash
sudo qemu-img info --force-share /path/to/image.qcow2
```

### Live commit and pivot

```bash
sudo virsh blockcommit HV01 vda \
  --active \
  --pivot \
  --verbose
```

### Remove only snapshot metadata

```bash
sudo virsh snapshot-delete HV01 before-changes --metadata
```

### Check whether an old overlay is still open

```bash
sudo lsof /path/to/snapshot-overlay
```

---

# Recommended Live Lab Workflow

The preferred workflow for this lab is:

```text
1. Check VM disks
        │
        ▼
2. Create external snapshot of vda ONLY
        │
        ▼
3. VM continues running
        │
        ▼
4. Make/test changes
        │
        ▼
5. Decide to KEEP the changes
        │
        ▼
6. virsh blockcommit --active --pivot
        │
        ▼
7. Verify "Successfully pivoted"
        │
        ▼
8. Verify vda points back to base QCOW2
        │
        ▼
9. Check/remove snapshot metadata
        │
        ▼
10. Verify old overlay is unused
        │
        ▼
11. Delete old overlay
```

For example:

```bash
# Check disks
sudo virsh domblklist HV01 --details

# Create snapshot
sudo virsh snapshot-create-as HV01 \
  --name "before-changes" \
  --description "Before configuration changes" \
  --disk-only \
  --atomic \
  --diskspec vda,snapshot=external \
  --diskspec sda,snapshot=no \
  --diskspec sdb,snapshot=no

# Make and test your changes...

# Verify current active disk
sudo virsh domblklist HV01 --details

# Keep changes and merge them into the base
sudo virsh blockcommit HV01 vda \
  --active \
  --pivot \
  --verbose

# Verify pivot
sudo virsh domblklist HV01 --details

# Check snapshot metadata
sudo virsh snapshot-list HV01

# If metadata remains
sudo virsh snapshot-delete HV01 before-changes --metadata

# Verify old overlay isn't being used
sudo lsof /var/lib/libvirt/images/HV01.before-changes

# Delete old overlay after verification
sudo rm /var/lib/libvirt/images/HV01.before-changes
```

---

# Keep vs. Revert

There is an important distinction when working with external snapshots.

## Keep the Changes

If the changes made after the snapshot are good:

```text
Overlay changes
      │
      ▼
Merge into original QCOW2
```

Use:

```bash
sudo virsh blockcommit HV01 vda --active --pivot --verbose
```

## Revert the Changes

If the changes made after the snapshot are bad and you want to return to the state from before the changes:

```text
HV01.before-changes   ← discard
        X

HV01.qcow2            ← return to this state
```

**Do not run `blockcommit`**, because `blockcommit` merges the changes you are trying to discard into the base disk.

Reverting an external snapshot requires a different procedure and should be treated separately from committing/keeping a snapshot.

---

# Key Rules

1. Snapshot the VM disk (`vda`), not the mounted ISO/CD-ROM devices.
2. External snapshots create an overlay on top of the original QCOW2 disk.
3. Seeing the original disk under `<backingStore>` is normal.
4. A running VM may lock its QCOW2 files; this is expected.
5. For a running VM, use `virsh blockcommit --active --pivot` to keep changes.
6. Do not use `qemu-img commit` on the active overlay of a running VM.
7. Always verify `domblklist` after a pivot.
8. Never delete an overlay until you have confirmed the VM is no longer using it.
9. `blockcommit` means **KEEP the changes**.
10. Reverting/discarding changes is a separate procedure.