# Nested Hyper-V Cluster Lab on KVM

## Network Architecture

```text
                           Home LAN (192.168.0.0/24)
                                   |
                           Router / Switch
                                   |
                            Physical NIC (eno2)
                                   |
                              Linux Bridge (br0)
                                   |
        +--------------------------+--------------------------+
        |                          |                          |
        |                          |                          |
+----------------+         +----------------+         +----------------+
|   HyperV01     |         |   HyperV02     |         |   Storage VM   |
+----------------+         +----------------+         +----------------+
| NIC1 (Mgmt)    |         | NIC1 (Mgmt)    |         | NIC1 (Mgmt)    |
| 192.168.0.11   |         | 192.168.0.12   |         | 192.168.0.20   |
+----------------+         +----------------+         +----------------+


                   Private Linux Bridge (br-iscsi)

        +--------------------------+--------------------------+
        |                          |                          |
        |                          |                          |
+----------------+         +----------------+         +----------------+
|   HyperV01     |         |   HyperV02     |         |   Storage VM   |
+----------------+         +----------------+         +----------------+
| NIC2 (iSCSI)   |         | NIC2 (iSCSI)   |         | NIC2 (iSCSI)   |
| 10.10.10.11    |<------->| 10.10.10.12    |<------->| 10.10.10.10    |
+----------------+         +----------------+         +----------------+


                  Private Linux Bridge (br-cluster)

                 +-----------------------------+
                 |                             |
                 |                             |
        +----------------+             +----------------+
        |   HyperV01     |             |   HyperV02     |
        +----------------+             +----------------+
        | NIC3 (Cluster) |             | NIC3 (Cluster) |
        | 10.10.20.11    |<----------->| 10.10.20.12    |
        +----------------+             +----------------+
          Heartbeat / Live Migration
```

---

# Network Summary

| Network | Linux Bridge | Subnet | Connected Systems | Gateway |
|----------|--------------|--------|-------------------|----------|
| Management | br0 | 192.168.0.0/24 | HyperV01, HyperV02, Storage VM | Yes (192.168.0.1) |
| iSCSI | br-iscsi | 10.10.10.0/24 | HyperV01, HyperV02, Storage VM | None |
| Cluster | br-cluster | 10.10.20.0/24 | HyperV01, HyperV02 | None |

---

# VM NIC Configuration

## HyperV01

| NIC | Purpose | IP Address |
|-----|----------|------------|
| NIC1 | Management | 192.168.0.11 |
| NIC2 | iSCSI | 10.10.10.11 |
| NIC3 | Cluster / Live Migration | 10.10.20.11 |

---

## HyperV02

| NIC | Purpose | IP Address |
|-----|----------|------------|
| NIC1 | Management | 192.168.0.12 |
| NIC2 | iSCSI | 10.10.10.12 |
| NIC3 | Cluster / Live Migration | 10.10.20.12 |

---

## Storage VM

| NIC | Purpose | IP Address |
|-----|----------|------------|
| NIC1 | Management | 192.168.0.20 |
| NIC2 | iSCSI Target | 10.10.10.10 |

> The Storage VM does **not** require a Cluster network adapter because it is not a member of the Hyper-V Failover Cluster.

---

# Traffic Flow

## Management Network (br0)

- Active Directory
- DNS
- RDP
- Hyper-V Manager
- Windows Admin Center
- Internet Access
- VM Client Traffic

---

## iSCSI Network (br-iscsi)

- HyperV01 ⇄ Storage VM
- HyperV02 ⇄ Storage VM
- CSV Storage
- MPIO (optional)

No gateway configured.

---

## Cluster Network (br-cluster)

- Cluster Heartbeat
- Live Migration
- CSV Redirected I/O (optional)

No gateway configured.

---

# Result

Each Hyper-V host has three dedicated networks:

- **Management** → Production LAN
- **iSCSI** → Shared Storage
- **Cluster** → Heartbeat & Live Migration

This closely mirrors a production Hyper-V cluster while remaining completely contained inside a single KVM host.