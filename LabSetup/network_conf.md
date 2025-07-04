# Network Configuration

This document explains how to attach virtual network interfaces (NICs) to each VM and assign static IP addresses so that:

1. **All domain machines** (DC, CLIENT1, CLIENT2) share an **"Internal LAN"** for AD traffic.  
2. **CLIENT1** and **KALI** also share a second "KaliNet" network for script‑sharing and attacker‑to‑target communication.

---

## 1. Virtual Hypervisor Setup

### A. Create Virtual Networks

1. **Internal LAN**  
   - Name: 'Internal'  
   - Type:  Internal Network (no external Internet)  
   - Subnet: 10.10.1.0/24

2. **KaliNet**  
   - Name: 'KaliNet'  
   - Type: Internal Network  
   - Subnet: 192.168.10.0/24


> [!NOTE]
> In VMware Workstation these are "Host‑only" networks; in VirtualBox they are "Internal Network"


## 2. Attach NICs to VMs

| VM       | NIC 1 (Internal) | NIC 2 (KaliNET) |
|----------|-----------------|-------------------|
| **DC**      | ✔️              | –                 |
| **CLIENT1** | ✔️              | ✔️                |
| **CLIENT2** | ✔️              | –                 |
| **KALI**    | –               | ✔️                |


## 3. Configure static IP

### A. On Windows VMs (DC, CLIENT1, CLIENT2)

1. Open **Network & Internet Settings** → **Ethernet** → **Change adapter options**.  
2. Right‑click the adapter for the correct network → **Properties**.  
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → **Properties**.  
4. Choose **"Use the following IP address"** and enter:

| VM        | Adapter      | IP Address      | Subnet Mask   | Default Gateway |
|-----------|--------------|-----------------|---------------|-----------------|
| **DC01**     | Internal      | 10.10.1.200 | 255.255.255.0 | 127.0.0.1 |
| **CLIENT1**  | Internal      | 10.10.1.201 | 255.255.255.0 | 10.10.1.200 |
| **CLIENT1**  | KaliNet    | 192.168.10.101 | 255.255.255.0 | 10.10.1.200 |
| **CLIENT2**  | Internal      | 10.10.1.202 | 255.255.255.0 | 10.10.1.200 |


### B. On Kali Linux (or other attacker host)

1. Identify the interface name for KaliNet (e.g. 'eth1'):  
  ```bash
   ip link show
   ```
2. Assign an static IP and bring up the interface
  ```bash
  sudo ip addr add 192.168.10.100/24 dev eth1
  sudo ip link set eth1 up
  ```

