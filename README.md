## Vulnerable Active Directory Lab
Automated custom-built vulnerable Active Directory environment designed to simulate a full attack chain. The lab includes intensional misconfigurations such as an exposed SMB share with users files, users accounts that are AS-REP roastable and Kerberoastable, and privilege escalation paths that allow password changes for a privilege user. Exploiting these weaknesses step-by-step leads to a successful DCSync attack and full domain compromise.
## Diagram
![diagrama](https://github.com/user-attachments/assets/8178b195-70bc-48bf-98a0-4e162078a346)
## Lab Topology
| Host | Role | NICs |IP| Vulns |
|------|------|------|--|-------|
| DC | Domain Controller | 1 NIC |10.10.1.200| AS-REProastable, Kerberoastable, Reset Password, DCSync |
| Client1 | Windows Client | 2 NICs |192.168.10.101  10.10.1.201|RDP, SeImpersonatePrivilege, Powershell History|
| Client2 | Windows Client | 1 NIC |10.10.1.202| SMB folder with zip file |
| Kali | Attacker | 1 NIC |192.168.10.100| Can pivot through Client1 |

## Lab Key Features
- Active Directory Automated Domain setup: Vulnerable users, weak passwords, delegated permissions, GPO disables Defender, Firewall, Updates
- Vulnerable User Accounts: Kerberoasting, AS-REProastable
- Privilege Escalation Paths: Reset Password, DCSync
- Hardening Bypass on CLIENT1: RDP Access, SeImpersonatePrivilege
- Exploitable SMB share on CLIENT2: SMB folder with zip file

## Lab Objective
The goal of this lab is to simulate a realistic attack chain in an Active Directory environment. It shows how common misconfigurations and overlooked settings can be combined to compromise an entire domain. It can be used as reference for pentesters portfolio.

## To Download:
[Windows 10 ISO](https://www.microsoft.com/en-au/software-download/windows10)

[Windows Server 2016 ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016)

## Environment Setup & Configuration
1. Import VMs in VirtualBox/VMware.

2. Assign Internal Network interfaces to VMs

3. Install Windows Server and Client ISO 

4. Create a new Forest on Windows Server
- Join CLIENTS to DC, all of them have to be in the same Internal network/share the same IP range
  ![lab39](https://github.com/user-attachments/assets/6a996f85-1fc5-482b-b40a-eb05093b6937)
- Add a second Internal Network adapter to kali and Client1 for communication from VM Manager
  ![lab42](https://github.com/user-attachments/assets/c38c8cc0-8ce2-4bad-9b21-79cfe1d06749)

- Set IP in CLIENT1 : 192.168.10.101
  ```
  Network & Internet Settings > Ethernet > Properties > IPv4
  IP: 192.168.10.101
  Netmask: 255.255.255.0
  ```
- Set IP in Kali : 192.168.10.100
  ```bash
  sudo ip addr add 192.168.10.100/24 dev eth1
  sudo ip link set eth1 up
  ```
5. Take a snapshot of all 3 machines
6. Download the scripts to your kali machine and share them with python to download them from CLIENT1
  ```
  python3 -m http.server80
  iwr -uri http://<IP>/<FILE> -Outfile <FILENAME>
  ```
7. In CLIENT1 put the downloaded files in a SMB Folder so they will be accessible from any machine (To do this we have to be connected in each machine as a Domain user/admin)

[c1_smbsharing.webm](https://github.com/user-attachments/assets/68b1fa6b-0e0d-4e47-834e-86624a632271)

## Domain and Clients configuration

### DC
-  On powershell we run DC_script.ps1, the script will create domain users, AS-RERProastble and Kerberoastable users, create a GPO to disable windows updates, firewall and defender, assign Reset Password and DCSync permissions.
```powershell
powershell -ep bypass
.\DC_SCRIPT.PS1
```
  - We restric LDAP queries for Nicol following the next steps. By restricting LDAP queries user Nicol won't be able to gather Domain info using tools as rpcclient or ldapsearch.
  ```
  Go to: Group Policy Management  
  	Group Policy Objects > Deny LDAP Access > Edit 
  		Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment
  			Deny Access to this computer from the network > Add User or Group > LDAP_Deny_Group
  ```
  - As the final step we link the GPO to the Domain Controllers ( The script already creates the Group and the GPO but manual step is necessary)
  ```
  Go to : Group Policy Management
  	Domain Controllers > Right click > Link an existing GPO > Deny LDAP Access > OK
  ```    
[DC.webm](https://github.com/user-attachments/assets/3a71db16-ee3c-4f5e-907c-5b2fbb517e85)

### CLIENT 2
- On powershell we run c2_script.ps1, this will create a SMB Folder and add Nicol to it
   ```powershell
   powershell -ep bypass
   .\c2_script.ps1
   ```
[CLIENT2.webm](https://github.com/user-attachments/assets/39afdffa-71ce-488a-a22b-bf809d1fbf73)

### CLIENT1
- On powershell we run c1_script.ps1, this will add user Adrian to Local RDP Group, enable RDP, and enable Administrator account
   ```powershell
   powershell -ep bypass
   .\c2_script.ps1
   ```
[CLIENT1.webm](https://github.com/user-attachments/assets/92b2a1a1-659f-4849-a4b9-5a9706e76378)

## Attack Flow
Read full write-up here 

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

## License
This project is licensed under the MIT License - see the LICENSE file for details.






