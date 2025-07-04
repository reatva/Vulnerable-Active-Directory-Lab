# Documentation Overview

This folder contains **professional write‑ups** for each post‑exploitation technique demonstrated in the lab.  Each document:

- Explains the misconfiguration or weakness  
- Maps the attack to MITRE ATT&CK  
- Walks through the step‑by‑step exploitation commands  
- Describes real‑world impact

---

## Exploitation Guides

| Technique            | File                          | MITRE ATT&CK ID  |
|----------------------|-------------------------------|------------------|
| Kerberoasting        | [Kerberoasting](/Documentation/kerberoasting.md)              | T1558.003        |
| AS-REP Roasting      | [AS-REP-Roasting](/Documentation/asrep.md)            | T1558.004        |
| DCSync               | [DCSync](/Documentation/DCSync.md)                     | T1003.003        |
| Golden Ticket        | Golden.md                     | T1550.003        |

> **Tip:** Click any file above to see the full, professional step‑by‑step guide.

---

## How to Use These Docs

1. **Read the Technique Overview** at the top of each file to understand when it applies.  
2. **Follow the “Lab Misconfiguration”** section to see how the vulnerability was introduced.  
3. **Execute the steps** in the “Exploitation” section on your lab VMs.  
4. **Review the “Impact”** notes to learn why this matters in real networks.

---

> These docs assume you have the lab up and running as per the main README and LabSetup instructions.
