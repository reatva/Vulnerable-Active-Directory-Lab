# Script Deployment

This document explains how to transfer and execute the PowerShell scripts that deploy the lab’s vulnerabilities and configurations on each host.

---

## 1. Host‑to‑Script Mapping

| Host        | Script          | Purpose                                                                                                                                 |
| ----------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **DC**      | DC_script.ps1 | Create domain users, AS-REP/Kerberoastable accounts, GPOs to disable updates, firewall, Defender, assign Reset Password & DCSync rights |
| **CLIENT1** | c1_script.ps1 | Add `Adrian` to RDP group, enable RDP & Administrator account, prepare SeImpersonatePrivilege                                           |
| **CLIENT2** | c2_script.ps1 | Configure SMB share with files (images.zip), miscellaneous settings                                                                     |

---

## 2. Sharing Scripts via HTTP

On **Kali (AttackerBox)**:

```bash
# Serve the directory containing your scripts and images on port 80
cd /path/to/scripts
python3 -m http.server 80
```

On **CLIENT1** (Domain Admin in an elevated PowerShell session):

```powershell
# Create a shared folder on CLIENT1 to distribute scripts
mkdir C:\FILES

# Download each file from Kali's HTTP server
$kaliIP = "<KALI_IP>"
Invoke-WebRequest -Uri "http://$kaliIP/DC_script.ps1" -OutFile "C:\FILES\DC_script.ps1"
Invoke-WebRequest -Uri "http://$kaliIP/c1_script.ps1" -OutFile "C:\FILES\c1_script.ps1"
Invoke-WebRequest -Uri "http://$kaliIP/c2_script.ps1" -OutFile "C:\FILES\c2_script.ps1"
Invoke-WebRequest -Uri "http://$kaliIP/images.zip" -OutFile "C:\FILES\images.zip"

# Share the folder so all domain machines can access it
New-SmbShare -Name SHARE -Path C:\SHARE -FullAccess "DOMAIN\Domain Admins"
```

> **Note:** All commands must be run in a PowerShell prompt with **Administrator** privileges.

---

## 3. Script Execution

### A. DC (Domain Controller)

1. **Connect** to "\\CLIENT1\FILES" and copy "DC_script.ps1" to "C:\TEMP" (or any folder).

2. Open PowerShell as Administrator on **DC**.

3. Run:

   ```powershell
   powershell -ep bypass
   C:\TEMP\DC_script.ps1
   ```

   This will:

   * Create user accounts (including AS-REP/Kerberoastable and Kerberoastable users)
   * Configure a GPO to disable Windows Updates, Firewall, and Defender
   * Grant Reset Password and DCSync privileges to designated users/groups

4. **Restrict LDAP queries for user `Nicol`** via Group Policy Management:

   * Navigate: **Group Policy Management** → **Group Policy Objects** → **Deny LDAP Access** → **Edit**
   * Path: *Computer Configuration* → *Policies* → *Windows Settings* → *Security Settings* → *Local Policies* → *User Rights Assignment*
   * Add `LDAP_Deny_Group` to **Deny access to this computer from the network**.

5. **Link GPO** to the Domain Controllers OU:

   * In **Group Policy Management**, right‑click **Domain Controllers** OU → **Link an existing GPO** → **Deny LDAP Access** → **OK**.


### B. CLIENT2

1. **Connect** to "\\CLIENT1\FILES" and copy "c2_script.ps1" and "images.zip" to "C:\".
2. Open PowerShell as Administrator on **CLIENT2**.
3. Run:

   ```powershell
   powershell -ep bypass
   C:\c2_script.ps1
   ```

   This will:

   * Configure an SMB share and place "images.zip" inside
   * Perform any additional setup required for CLIENT2 exploitation

### C. CLIENT1

1. **Connect** to "\\CLIENT1\FILES" and copy "c1_script.ps1" to "C:\TEMP".

2. Open PowerShell as Administrator on **CLIENT1**.

3. Run:

   ```powershell
   powershell -ep bypass
   C:\TEMP\c1_script.ps1
   ```

   This will:

   * Add user "Adrian" to the local Remote Desktop Users group
   * Enable RDP and the local "Administrator" account

4. **Assign SeImpersonatePrivilege** to user `Adrian` via Local Security Policy:

   * Open **Local Security Policy**: *Windows Administrative Tools* → *Local Security Policy*
   * Navigate: *Local Policies* → *User Rights Assignment* → **Impersonate a client after authentication**
   * Add **Adrian**.

5. **Simulate exploitation path** by dropping into a high‑privilege shell for user 'Nicol'. Log-in as Administrator and in powershell:

   ```powershell
   runas.exe /user:Nicol /password:Ready4@ll! cmd.exe
   ```

---

## 4. Validation & Testing

* **DC**: Verify new accounts in **Active Directory Users and Computers**, check GPO settings.
* **CLIENT2**: Access the SMB share from another host:

  ```powershell
  Test-Path \\CLIENT2\SHARE\images.zip
  ```
* **CLIENT1**: Confirm RDP connectivity and Administrator account is enabled.
* From **Kali**, ensure you can download files:

  ```bash
  wget http://192.168.10.101/images.zip
  ```

---

**Snapshot your VMs before running any scripts so you can revert if needed.**
