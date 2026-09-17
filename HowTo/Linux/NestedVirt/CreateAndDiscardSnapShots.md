# KVM / Libvirt – Revert an External Snapshot

This guide explains how to **revert a KVM virtual machine to its state before an external snapshot was created**.

Use this procedure when changes made after creating the snapshot are **not wanted** and should be discarded.

> **Important:** Reverting this way permanently discards everything written to the snapshot overlay after the snapshot was created.

---

# Understanding the Snapshot

After creating an external snapshot, the VM uses an overlay disk.

For example:

```text
HV01 VM
   │
   ▼
HV01.before-changes       ← ACTIVE overlay
   │
   ▼
HV01.qcow2                ← ORIGINAL/base disk
```

The original `HV01.qcow2` is effectively the point-in-time state from when the snapshot was created.

Changes made afterward are written to:

```text
HV01.before-changes
```

If those changes are unwanted, the goal is to discard the overlay and reconnect the VM directly to:

```text
HV01.qcow2
```

The final configuration will be:

```text
HV01 VM
   │
   ▼
HV01.qcow2

HV01.before-changes       ← discarded
```

> **DO NOT use `blockcommit` when reverting.**
>
> `blockcommit` merges the changes from the overlay into the original disk. That is the opposite of what we want when reverting.

---

# 1. Check the Current VM Disk

Before doing anything, check the VM's current disks:

```bash
sudo virsh domblklist HV01 --details
```

You should see something similar to:

```text
Type   Device   Target   Source
-----------------------------------------------------------------------
file   disk     vda      /var/lib/libvirt/images/HV01.before-changes
file   cdrom    sda      /var/lib/libvirt/images/Server2022.iso
file   cdrom    sdb      /var/lib/libvirt/images/virtio-win.iso
```

The important line is:

```text
vda   /var/lib/libvirt/images/HV01.before-changes
```

This confirms that the VM is currently using the external snapshot overlay.

---

# 2. Identify the Original Disk

The VM XML can be used to verify the relationship between the overlay and the original disk.

Run:

```bash
sudo virsh dumpxml HV01
```

Look for the `vda` disk.

It should look similar to:

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

This confirms:

```text
HV01.before-changes
        │
        ▼
HV01.qcow2
```

where:

- `HV01.before-changes` = changes made after the snapshot
- `HV01.qcow2` = original state you want to return to

---

# 3. Shut Down the VM

Unlike keeping the changes with `blockcommit --active --pivot`, the recommended lab procedure for discarding the active overlay is to shut down the VM.

Run:

```bash
sudo virsh shutdown HV01
```

Check the VM state:

```bash
sudo virsh domstate HV01
```

Wait until it reports:

```text
shut off
```

Do not continue until the VM is completely shut down.

---

# 4. Edit the VM Disk Configuration

Edit the VM:

```bash
sudo virsh edit HV01
```

Find the `vda` disk configuration.

It will currently look similar to:

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

Change the source from:

```xml
<source file='/var/lib/libvirt/images/HV01.before-changes'/>
```

to:

```xml
<source file='/var/lib/libvirt/images/HV01.qcow2'/>
```

Remove the `<backingStore>` section associated with the old overlay.

The resulting disk configuration should look similar to:

```xml
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2'/>
  <source file='/var/lib/libvirt/images/HV01.qcow2'/>
  <target dev='vda' bus='virtio'/>
</disk>
```

> Keep any other existing settings inside the `<disk>` section, such as addresses, serial numbers, boot order, or other VM-specific settings.

Only change the disk source and remove the obsolete backing-store relationship.

Save and exit the editor.

---

# 5. Verify the VM Configuration

Before starting the VM or deleting anything, verify the disk configuration:

```bash
sudo virsh domblklist HV01 --details
```

You want to see:

```text
file   disk   vda   /var/lib/libvirt/images/HV01.qcow2
```

You should **NOT** see:

```text
vda   /var/lib/libvirt/images/HV01.before-changes
```

The VM is now configured like this:

```text
HV01 VM
   │
   ▼
HV01.qcow2

HV01.before-changes       ← no longer attached
```

---

# 6. Remove Snapshot Metadata

Check whether libvirt still has metadata for the snapshot:

```bash
sudo virsh snapshot-list HV01
```

You may see:

```text
Name             Creation Time               State
-------------------------------------------------------
before-changes   2026-09-17 05:00:00 -0400   disk-snapshot
```

Remove only the snapshot metadata:

```bash
sudo virsh snapshot-delete HV01 before-changes --metadata
```

Check again:

```bash
sudo virsh snapshot-list HV01
```

The list should now be empty.

> `--metadata` removes libvirt's record of the snapshot. It does not merge the unwanted overlay into the original disk.

---

# 7. Start the VM

Start the VM:

```bash
sudo virsh start HV01
```

Verify:

```bash
sudo virsh domstate HV01
```

You should see:

```text
running
```

Check the active disk again:

```bash
sudo virsh domblklist HV01 --details
```

It should still show:

```text
file   disk   vda   /var/lib/libvirt/images/HV01.qcow2
```

---

# 8. Verify the Revert

Log into the VM and make sure:

- Windows boots normally.
- The VM is operating correctly.
- Changes made after `before-changes` are gone.
- The VM is back in the expected state.

At this point:

```text
           HV01 VM
              │
              ▼
        HV01.qcow2
        ORIGINAL STATE


HV01.before-changes
        │
        └──── Unused old overlay
```

Do **not** delete the overlay until you have verified the VM.

---

# 9. Verify the Old Overlay Is Not Being Used

Check whether any process still has the overlay open:

```bash
sudo lsof /var/lib/libvirt/images/HV01.before-changes
```

Normally, nothing should be returned.

Also check the VM disk one final time:

```bash
sudo virsh domblklist HV01 --details
```

Confirm:

```text
vda   /var/lib/libvirt/images/HV01.qcow2
```

---

# 10. Delete the Old Overlay

Once the VM has been verified and the old overlay is no longer being used:

```bash
sudo rm /var/lib/libvirt/images/HV01.before-changes
```

The revert is now complete.

---

# Complete Revert Procedure

```bash
# 1. Check current disk
sudo virsh domblklist HV01 --details

# 2. Review XML and identify the backing/base disk
sudo virsh dumpxml HV01

# 3. Shut down the VM
sudo virsh shutdown HV01

# 4. WAIT until completely shut down
sudo virsh domstate HV01

# 5. Edit the VM
sudo virsh edit HV01

# Change vda from the overlay:
# /var/lib/libvirt/images/HV01.before-changes
#
# back to:
# /var/lib/libvirt/images/HV01.qcow2
#
# Remove the obsolete <backingStore> section.

# 6. VERIFY before doing anything destructive
sudo virsh domblklist HV01 --details

# 7. Check snapshot metadata
sudo virsh snapshot-list HV01

# 8. Remove metadata if it still exists
sudo virsh snapshot-delete HV01 before-changes --metadata

# 9. Start the VM
sudo virsh start HV01

# 10. Verify active disk
sudo virsh domblklist HV01 --details

# 11. Make sure the old overlay isn't open
sudo lsof /var/lib/libvirt/images/HV01.before-changes

# 12. After verifying the VM, delete the discarded overlay
sudo rm /var/lib/libvirt/images/HV01.before-changes
```

---

# KEEP vs. REVERT

## KEEP Changes

If the changes are good and should become permanent, the VM can remain running:

```bash
sudo virsh blockcommit HV01 vda \
  --active \
  --pivot \
  --verbose
```

This performs:

```text
Overlay
   │
   │ MERGE
   ▼
Base QCOW2
```

Result:

```text
HV01
  │
  ▼
HV01.qcow2
  +
all changes since snapshot
```

---

## REVERT Changes

If the changes are bad and should be discarded:

```text
Overlay
   │
   └──── DISCARD

Base QCOW2
   │
   └──── RETURN HERE
```

Do **NOT** run:

```bash
virsh blockcommit
```

Instead:

```text
Shutdown VM
     │
     ▼
Point vda back to base QCOW2
     │
     ▼
Remove snapshot metadata
     │
     ▼
Start VM
     │
     ▼
Verify rollback
     │
     ▼
Delete old overlay
```

---

# Golden Rule

When deciding what to do with an external snapshot:

```text
                    Are the changes good?
                           │
                 ┌─────────┴─────────┐
                 │                   │
                YES                  NO
                 │                   │
                 ▼                   ▼
               KEEP                REVERT
                 │                   │
                 ▼                   ▼
           blockcommit          DO NOT COMMIT
        --active --pivot             │
                 │                   ▼
                 │              Shutdown VM
                 │                   │
                 │                   ▼
                 │            Point back to base
                 │                   │
                 ▼                   ▼
            Delete old          Start & verify
              overlay                │
                                     ▼
                              Delete old overlay
```

> **KEEP = Commit the overlay**
>
> **REVERT = Discard the overlay**

Never run `blockcommit` if your goal is to discard the changes made after the snapshot.