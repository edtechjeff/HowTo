# Hyper-V Dedicated Live Migration Network

This guide walks through creating a dedicated Live Migration network between two Hyper-V servers running as virtual machines on a KVM/libvirt host.

## Network Design

The dedicated Live Migration network used in this lab is:

| Server | Live Migration IP | Subnet |
| ------ | ----------------: | -----: |
| HV01   |     `10.10.40.31` |  `/24` |
| HV02   |     `10.10.40.32` |  `/24` |

Network:

```text
10.10.40.0/24
```

No default gateway or DNS server is required on this network.

The basic design is:

```text
                    KVM HOST
              ┌───────────────────┐
              │                   │
              │       br0         │
              │   Management      │
              │                   │
              │  br-migration     │
              │         │         │
              │    ┌────┴────┐    │
              │    │         │    │
              │   HV01      HV02  │
              │    │         │    │
              │ .31│         │.32 │
              │    └────┬────┘    │
              │         │         │
              │   10.10.40.0/24   │
              └───────────────────┘
```

---

# 1. Create the KVM Live Migration Bridge

On the Ubuntu KVM host, edit the Netplan configuration:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Before making changes, it is a good idea to create a backup:

```bash
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.before-migration
```

Under the existing `bridges:` section, add:

```yaml
    br-migration:
      interfaces: []
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```

For example:

```yaml
  bridges:
    br0:
      interfaces:
        - eno2
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0

    br-iscsi:
      interfaces:
        - ens2f0
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0

    br-cluster:
      interfaces: []
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0

    br-migration:
      interfaces: []
      dhcp4: false
      dhcp6: false
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```

Because HV01 and HV02 are running on the same KVM host, `br-migration` does not require a physical NIC.

It acts as an internal Layer 2 network between the virtual machines.

---

# 2. Validate Netplan

Before applying the configuration:

```bash
sudo netplan generate
```

If no errors are returned:

```bash
sudo netplan apply
```

Verify the bridge:

```bash
ip -br link | grep br-
```

You should see:

```text
br-iscsi
br-cluster
br-migration
```

The bridge may initially show `DOWN` if no VM interfaces are connected to it yet.

---

# 3. Add the Live Migration NIC to HV01

Use a unique MAC address for each server.

For HV01:

```text
52:54:00:40:00:01
```

Attach the NIC:

```bash
sudo virsh attach-interface HV01 \
  --type bridge \
  --source br-migration \
  --model virtio \
  --mac 52:54:00:40:00:01 \
  --live \
  --config
```

The `--live` option adds the NIC to the running VM.

The `--config` option makes the NIC persistent so it remains after a reboot.

Verify:

```bash
sudo virsh domiflist HV01
```

You should see something similar to:

```text
Interface   Type     Source         Model    MAC
--------------------------------------------------------------
vnet7       bridge   br0            virtio   52:54:00:10:00:01
vnetXX      bridge   br-migration   virtio   52:54:00:40:00:01
```

---

# 4. Add the Live Migration NIC to HV02

HV02 must have a **different MAC address**.

Use:

```text
52:54:00:40:00:02
```

Attach it:

```bash
sudo virsh attach-interface HV02 \
  --type bridge \
  --source br-migration \
  --model virtio \
  --mac 52:54:00:40:00:02 \
  --live \
  --config
```

Verify:

```bash
sudo virsh domiflist HV02
```

Expected configuration:

```text
Interface   Type     Source         Model    MAC
--------------------------------------------------------------
vnet10      bridge   br0            virtio   52:54:00:10:00:02
vnetXX      bridge   br-migration   virtio   52:54:00:40:00:02
```

> **Important:** Every virtual NIC must have a unique MAC address. Duplicate MAC addresses can cause intermittent or complete Layer 2 communication failures.

---

# 5. Verify the KVM Bridge

Run:

```bash
bridge link
```

The virtual NICs for HV01 and HV02 should show:

```text
master br-migration
```

You can also check:

```bash
ip -br link
```

Once VM interfaces are connected, `br-migration` should normally show as active.

---

# 6. Identify the New NIC in Windows

On HV01 and HV02:

```powershell
Get-NetAdapter |
    Format-Table Name,Status,MacAddress,LinkSpeed -Auto
```

On HV01, look for:

```text
52-54-00-40-00-01
```

On HV02, look for:

```text
52-54-00-40-00-02
```

Rename the adapters to make their purpose obvious.

Example:

```powershell
Rename-NetAdapter `
    -Name "Ethernet 2" `
    -NewName "LiveMigration"
```

Verify:

```powershell
Get-NetAdapter
```

---

# 7. Configure HV01 IP Address

Configure HV01 with:

```text
IP:      10.10.40.31
Mask:    255.255.255.0
Gateway: NONE
DNS:     NONE
```

PowerShell:

```powershell
New-NetIPAddress `
    -InterfaceAlias "LiveMigration" `
    -IPAddress 10.10.40.31 `
    -PrefixLength 24
```

---

# 8. Configure HV02 IP Address

Configure HV02 with:

```text
IP:      10.10.40.32
Mask:    255.255.255.0
Gateway: NONE
DNS:     NONE
```

PowerShell:

```powershell
New-NetIPAddress `
    -InterfaceAlias "LiveMigration" `
    -IPAddress 10.10.40.32 `
    -PrefixLength 24
```

---

# 9. Disable DNS Registration

The dedicated Live Migration NIC should not register itself in Active Directory DNS.

Run on both servers:

```powershell
Set-DnsClient `
    -InterfaceAlias "LiveMigration" `
    -RegisterThisConnectionsAddress $false
```

Verify:

```powershell
Get-DnsClient `
    -InterfaceAlias "LiveMigration" |
    Format-List InterfaceAlias,RegisterThisConnectionsAddress
```

Expected:

```text
RegisterThisConnectionsAddress : False
```

---

# 10. Test the Dedicated Network

From HV01:

```powershell
ping 10.10.40.32
```

or:

```powershell
Test-NetConnection 10.10.40.32
```

From HV02:

```powershell
ping 10.10.40.31
```

or:

```powershell
Test-NetConnection 10.10.40.31
```

Both directions must work before configuring Hyper-V Live Migration.

Expected result:

```text
PingSucceeded : True
```

---

# 11. Enable Hyper-V Live Migration

Run on both HV01 and HV02:

```powershell
Enable-VMMigration
```

Verify:

```powershell
Get-VMHost |
    Select-Object VirtualMachineMigrationEnabled
```

Expected:

```text
VirtualMachineMigrationEnabled
------------------------------
True
```

---

# 12. Configure Authentication

For a simple lab configuration, CredSSP can be used:

```powershell
Set-VMHost `
    -VirtualMachineMigrationAuthenticationType CredSSP
```

CredSSP is convenient for testing, but the migration generally needs to be initiated while logged onto the source Hyper-V server.

For production/domain environments, Kerberos can be configured instead, but that requires the appropriate delegation configuration in Active Directory.

---

# 13. Configure Live Migration Performance

Configure SMB as the Live Migration performance option:

```powershell
Set-VMHost `
    -VirtualMachineMigrationPerformanceOption SMB
```

The authentication and performance settings can also be configured together:

```powershell
Set-VMHost `
    -VirtualMachineMigrationAuthenticationType CredSSP `
    -VirtualMachineMigrationPerformanceOption SMB
```

Run this on both Hyper-V hosts.

Verify:

```powershell
Get-VMHost |
    Select-Object VirtualMachineMigrationEnabled,
                  VirtualMachineMigrationAuthenticationType,
                  VirtualMachineMigrationPerformanceOption
```

---

# 14. View Current Live Migration Networks

Before changing the allowed networks:

```powershell
Get-VMMigrationNetwork
```

This displays the networks Hyper-V is currently allowed to use for Live Migration.

---

# 15. Restrict Live Migration to the Dedicated Network

The goal is for Hyper-V to use:

```text
10.10.40.0/24
```

rather than the normal management network.

If necessary, remove existing migration networks:

```powershell
Get-VMMigrationNetwork |
    Remove-VMMigrationNetwork
```

Then add the dedicated network:

```powershell
Add-VMMigrationNetwork "10.10.40.0/24"
```

Run this configuration on both HV01 and HV02.

Verify:

```powershell
Get-VMMigrationNetwork
```

The dedicated subnet should be listed:

```text
10.10.40.0/24
```

---

# 16. Verify the Complete Configuration

On HV01:

```powershell
Get-NetIPAddress `
    -InterfaceAlias "LiveMigration" `
    -AddressFamily IPv4

Get-VMMigrationNetwork

Get-VMHost |
    Select-Object VirtualMachineMigrationEnabled,
                  VirtualMachineMigrationAuthenticationType,
                  VirtualMachineMigrationPerformanceOption
```

HV01 should show:

```text
LiveMigration
10.10.40.31/24
```

On HV02:

```powershell
Get-NetIPAddress `
    -InterfaceAlias "LiveMigration" `
    -AddressFamily IPv4

Get-VMMigrationNetwork

Get-VMHost |
    Select-Object VirtualMachineMigrationEnabled,
                  VirtualMachineMigrationAuthenticationType,
                  VirtualMachineMigrationPerformanceOption
```

HV02 should show:

```text
LiveMigration
10.10.40.32/24
```

---

# 17. Test Live Migration

Start a test virtual machine on HV01.

Verify it is running:

```powershell
Get-VM
```

The VM should show:

```text
State
-----
Running
```

A clustered VM can then be moved through Failover Cluster Manager:

```text
Roles
  ↓
Select VM
  ↓
Move
  ↓
Live Migration
  ↓
Select Node
  ↓
HV02
```

The VM should remain running while its active state is transferred from HV01 to HV02.

---

# 18. Watch Live Migration Traffic

A useful demonstration is watching the dedicated NIC while the VM moves.

Run:

```powershell
Get-Counter `
    '\Network Interface(*)\Bytes Total/sec' `
    -Continuous
```

Or use Task Manager:

```text
Task Manager
   ↓
Performance
   ↓
Ethernet / LiveMigration
```

Start the Live Migration.

Traffic should increase substantially on the `LiveMigration` adapter while the VM's running state and memory are transferred.

This demonstrates that the dedicated `10.10.40.0/24` network is actually carrying the migration traffic.

---

# Final Network Layout

```text
                         HYPER-V LAB

                HV01                     HV02
          ┌───────────────┐        ┌───────────────┐
          │               │        │               │
Mgmt      │ 192.168.0.31  │        │ 192.168.0.x   │
          │       │       │        │       │       │
          └───────┼───────┘        └───────┼───────┘
                  │                         │
                  └──────── br0 ────────────┘


                HV01                     HV02
          ┌───────────────┐        ┌───────────────┐
          │ 10.10.40.31   │        │ 10.10.40.32   │
          │       │       │        │       │       │
          └───────┼───────┘        └───────┼───────┘
                  │                         │
                  └──── br-migration ───────┘
                         10.10.40.0/24

                         ↑
                         │
                  LIVE MIGRATION
                         │
                  VM running state
                  and memory traffic
```

# Troubleshooting

## Live Migration NIC Cannot Ping

Verify the IP addresses:

```powershell
Get-NetIPAddress -AddressFamily IPv4
```

Verify the adapters:

```powershell
Get-NetAdapter
```

Check that each NIC has a unique MAC address.

HV01:

```text
52:54:00:40:00:01
```

HV02:

```text
52:54:00:40:00:02
```

On the KVM host:

```bash
sudo virsh domiflist HV01
sudo virsh domiflist HV02
```

Both NICs must use:

```text
Source: br-migration
```

---

## Check for Duplicate NICs

Check the running VM configuration:

```bash
sudo virsh domiflist HV02
```

Check the persistent configuration:

```bash
sudo virsh domiflist HV02 --inactive
```

A server should have only **one** Live Migration NIC.

For example:

```text
br0            virtio   52:54:00:10:00:02
br-migration   virtio   52:54:00:40:00:02
```

Duplicate virtual NICs, especially with duplicate MAC addresses, must be corrected before troubleshooting Windows networking.

---

# Key Points

* Live Migration should use its own dedicated network when possible.
* The Live Migration NIC does not require a default gateway.
* The Live Migration NIC does not require DNS.
* Disable DNS registration on the dedicated NIC.
* Each VM NIC must have a unique MAC address.
* Both Hyper-V hosts must be able to communicate directly across the Live Migration subnet.
* Hyper-V should be configured to use `10.10.40.0/24` for migration traffic.
* CredSSP is convenient for a lab.
* Kerberos is generally preferable when properly configured for domain-based remote administration.
* Live Migration allows a running VM to move between Hyper-V hosts with minimal service interruption.
* Shared storage means the VM's storage can remain in place while its active running state is transferred between cluster nodes.
