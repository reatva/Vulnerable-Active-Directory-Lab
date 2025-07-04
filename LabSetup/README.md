## Environment Setup & Configuration

This section summarizes how to stand up the lab.

1. **Prepare VMs & ISOs**  
  - Download and import Windows Server 2016 & Windows 10 images  
  - See: [VM Preparation](/LabSetup/VM_prep.md) 

2. **Configure Networking**  
  - Attach internal NICs, assign static IPs  
  - See: [Network Configuration](/LabSetup/network_conf.md)

3. **Deploy AD & Join Clients**  
  - Promote DC01, join CLIENT1 & CLIENT2 to 'mydomain.com'  

4. **Run Misconfiguration Scripts**  
  - Execute `DC_script.ps1` on DC  
  - Execute `c2_script.ps1` on CLIENT2  
  - Execute `c1_script.ps1` on CLIENT1  
  - See: [Script Deployment](/LabSetup/scripts_deploy.md)

> **Tip**: Snapshot each VM before you run the scripts so you can revert and test multiple scenarios.

