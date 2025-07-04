## Vulnerable Active Directory Lab

A professionally structured Active Directory (AD) lab environment designed for hands-on learning and security testing. This lab simulates common real-world misconfigurations and vulnerabilities found in enterprise Windows domains, making it ideal for red team training, blue team defense, and purple team analysis.

![Alt text](/diagram.jpg)

## Objectives
- Design and build a vulnerable Active Directory environment from scratch.
- Deploy a realistic and intentional vulnerabilities found in Windows domains.
- Perform hands-on exploitation of AD attack paths, including:
  - Kerberoasting 
  - ASRERProasting
  - DCSync
- Document exploitation steps and techniques for learning and portfolio demonstration.

> [!NOTE]
> This lab is focused purely on **offensive exploitation** with no blue team components(detection or mitigation).

## Lab Architecture
| Host | Role | NICs |IP| OS |
|------|------|------|--|-------|
| DC | Domain Controller | 1 NIC |10.10.1.200| Windows Server 2016 |
| Client1 | Windows Client | 2 NICs |192.168.10.101  10.10.1.201| Windows 10 |
| Client2 | Windows Client | 1 NIC |10.10.1.202| Windows 10 |
| Kali | Attacker | 1 NIC |192.168.10.100| Atatcker Box |

## Technologies Used
- Active Directory Domain Services
- Group Policy
- Powershell
- Bash
- Impacket tools

## Lab Key Features
- Active Directory Automated Domain setup: Weak passwords, delegated permissions, GPO disables Defender, Firewall, Updates
- Vulnerable User Accounts: Kerberoasting, AS-REProastable
- Privilege Escalation Paths: Reset Password, DCSync
- Hardening Bypass on CLIENT1: RDP Access, SeImpersonatePrivilege
- Exploitable SMB share on CLIENT2: SMB folder with zip file
- Walktrough OSCP Style + Template using [Sysreptor](https://github.com/Syslifters/sysreptor)

## Attack Flow
[READ FULL WRITE-UP HERE](/Writeup/Lab-Walktrough.pdf)

- Step 1: Initial Access
  Weak domain creds used to RDP to Client1


- Step 2: Privilege Escalation
  Potato exploit (SeImpersonatePrivilege) used to get SYSTEM shell


- Step 3: Credential Discovery
  Found cleartext creds in Administrator’s PowerShell history


- Step 4: Lateral Movement
  Access SMB share on Client2 using creds

- Step 5: Data Collection & Credential Cracking
  Download and crack ZIP file hash, extract usernames from images

- Step 6: AS-REP Roasting
  Identify and crack ASREPRoastable user hash

- Step 7: Kerberoasting
  Extract and crack SPN ticket hash

- Step 8: Privilege Escalation via BloodHound
  Discover resetpassword chain and DCSync privileges

- Step 9: Credential Dumping (DCSync)
  Dump NTDS hashes

- Step 10: Persistence
  Forge Golden Ticket for persistence


## Mitre ATT&CK Coverage
- Use [ATTACK-navigator](/Documentation/ATTACK-navigator-v4.5.json) file and uploaded it [HERE](https://mitre-attack.github.io/attack-navigator/) to see full attack matrix.

| Tactic               | Technique                                      | ID        | NOTES                                         |
| -------------------- | ---------------------------------------------- | --------- | ----------------------------------------------------- |
| Initial Access       | Valid Accounts                                 | T1078     | Weak creds for RDP                                    |
| Execution            | Remote Desktop Protocol                        | T1021.001 | RDP session                                           |
| Privilege Escalation | Access Token Manipulation: Token Impersonation | T1134.001 | Potato exploit (SeImpersonatePrivilege)               |
| Credential Access    | Unsecured Credentials                          | T1552     | Cleartext creds in Administrator’s PowerShell history |
| Lateral Movement     | Remote Services: SMB/Windows Admin Shares      | T1021.002 | Access Client2 share                                  |
| Collection           | Data from Local System                         | T1005     | Download and extract files from ZIP                   |
| Credential Access    | Password Cracking                              | T1110.002 | Crack ZIP hash, AS-REP hash, SPN hash                 |
| Credential Access    | AS-REP Roasting                                | T1558.004 | Crack ASREPRoastable user                             |
| Credential Access    | Kerberoasting                                  | T1558.003 | Crack SPN user                                        |
| Credential Access    | OS Credential Dumping: NTDS                    | T1003.003 | DCSync                                                |
| Persistence          | Golden Ticket                                  | T1550.003 | Forge Golden Ticket                                   |


## Disclaimer
> [!NOTE] 
> This lab is for educational and ethical purposes only. Never use these techniques on systems you do not own or have explicit permission to test.




