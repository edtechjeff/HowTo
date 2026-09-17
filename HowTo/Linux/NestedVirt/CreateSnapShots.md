# KVM / Libvirt VM Snapshots

This guide covers creating and managing snapshots for KVM virtual machines using `virsh` and `qcow2` disks.

> **Important:** A snapshot is not a backup. Snapshots are useful for quickly rolling a VM back before testing or configuration changes.

## 1. Check the VM and Its Disks

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

* `vda` is the actual VM disk.
* `sda` is the Windows installation ISO.
* `sdb` is the VirtIO driver ISO.

Only `vda` needs to be snapshotted.

---

## 2. Check the QCOW2 Disk

If the VM is running, `qemu-img` may report a write-lock error.

Use `--force-share` to inspect the disk safely:

```bash
sudo qemu-img info --force-share \
  /var/lib/libvirt/images/HV01.qcow2
```

Verify that the disk reports:

```text
file format: qcow2
corrupt: false
```

---

# Creating an External Snapshot

For this environment, explicitly tell libvirt to snapshot `vda` and **not** the CD-ROM devices.

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
HV01.qcow2
     │
     └── Snapshot Overlay
              │
              └── HV01 writes new changes here
```

The original `HV01.qcow2` becomes the backing image and new disk changes are written to the overlay.

## Verify the Snapshot

```bash
sudo virsh snapshot-list HV01
```

For more information:

```bash
sudo virsh snapshot-info HV01 before-changes
```

Check which disk the running VM is currently using:

```bash
sudo virsh domblklist HV01 --details
```

After an external snapshot, `vda` should point to the new overlay rather than directly to `HV01.qcow2`.

---

# Inspecting the Snapshot Chain

Find the current overlay:

```bash
sudo virsh domblklist HV01
```

Then examine its backing chain:

```bash
sudo qemu-img info --backing-chain /path/to/snapshot-overlay
```

You should see something similar to:

```text
Snapshot Overlay
      ↓
HV01.qcow2
```

This means the overlay contains changes made since the snapshot and `HV01.qcow2` is the base disk.

---

# Keeping the Changes and Removing the Snapshot

If you are happy with the changes made after the snapshot, they can be committed back into the original disk.

For the safest/simple lab workflow, shut down the VM first:

```bash
sudo virsh shutdown HV01
```

Verify:

```bash
sudo virsh domstate HV01
```

It should report:

```text
shut off
```

Determine the current overlay:

```bash
sudo virsh domblklist HV01
```

Then commit the overlay:

```bash
sudo qemu-img commit /path/to/HV01-snapshot-overlay
```

This writes the changes from the overlay back into the backing `HV01.qcow2` disk.

Remove the snapshot metadata:

```bash
sudo virsh snapshot-delete HV01 before-changes --metadata
```

After committing an external snapshot, verify the VM's disk configuration before deleting the overlay.

```bash
sudo virsh domblklist HV01 --details
```

If necessary, edit the VM:

```bash
sudo virsh edit HV01
```

Make sure `vda` points back to:

```xml
<driver name='qemu' type='qcow2'/>
<source file='/path/to/HV01.qcow2'/>
<target dev='vda' bus='virtio'/>
```

Start the VM and verify that Windows boots correctly:

```bash
sudo virsh start HV01
```

**Do not delete the old overlay until the VM has successfully booted and its data has been verified.**

---

# Important Lesson: Do Not Snapshot ISO Drives

Avoid creating an external snapshot without specifying which disks should participate.

For example, using only:

```bash
sudo virsh snapshot-create-as HV01 \
  --name "before-changes" \
  --disk-only \
  --atomic
```

may cause libvirt to create QCOW2 overlays for CD-ROM devices as well.

You could end up with:

```text
vda → HV01.snapshot
sda → Server2022.iso.snapshot
sdb → virtio-win.iso.snapshot
```

This unnecessarily complicates snapshot removal.

Instead, explicitly exclude the CD-ROMs:

```bash
--diskspec vda,snapshot=external \
--diskspec sda,snapshot=no \
--diskspec sdb,snapshot=no
```

---

# Fixing an ISO/QCOW2 Format Problem

If an external snapshot accidentally included the CD-ROM drives, you may encounter:

```text
Image is not in qcow2 format
```

This can happen when the VM is pointed back to an `.iso`, but its XML still identifies the device as QCOW2.

Edit the VM:

```bash
sudo virsh edit HV01
```

A normal ISO/CD-ROM should use:

```xml
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/path/to/Server2022.iso'/>
  <target dev='sda' bus='sata'/>
  <readonly/>
</disk>
```

The important difference is:

```xml
type='raw'
```

An ISO is a raw image, not QCOW2.

The VM's main disk should still use:

```xml
<driver name='qemu' type='qcow2'/>
```

---

# Useful Snapshot Commands

List snapshots:

```bash
sudo virsh snapshot-list HV01
```

Get snapshot details:

```bash
sudo virsh snapshot-info HV01 before-changes
```

View snapshot XML:

```bash
sudo virsh snapshot-dumpxml HV01 before-changes
```

Check VM disks:

```bash
sudo virsh domblklist HV01 --details
```

Check VM state:

```bash
sudo virsh domstate HV01
```

Inspect a QCOW2 backing chain:

```bash
sudo qemu-img info --backing-chain /path/to/overlay.qcow2
```

Remove only libvirt snapshot metadata:

```bash
sudo virsh snapshot-delete HV01 before-changes --metadata
```

---

# Recommended Lab Workflow

Before making major changes:

```text
1. Check VM disks
        ↓
2. Create external snapshot of vda ONLY
        ↓
3. Make/test changes
        ↓
4. Test everything
        ↓
5. Shut down VM
        ↓
6. Commit snapshot if keeping changes
        ↓
7. Point VM back to base QCOW2
        ↓
8. Start VM and verify
        ↓
9. Delete old overlay only after verification
```

For VMs with mounted installation or VirtIO ISOs, always exclude those CD-ROM devices from the snapshot.
