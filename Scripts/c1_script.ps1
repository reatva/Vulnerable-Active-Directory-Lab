```powershell
# Ensure parent path exists
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defender")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defender" -Force
}

# Then set the value
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

# Disabling Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Adding adrian to RDP
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "mydomain.com\adrian"

# Enabling RDP
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
$Name = "fDenyTSConnections"

if (Get-ItemProperty -Path $RegPath -Name $Name -ErrorAction SilentlyContinue) {
    Write-Host "Value exists, updating..."
} else {
    Write-Host "Value does not exist, creating..."
}

Set-ItemProperty -Path $RegPath -Name $Name -Value 0

# Create user admin
net user Administrator 'UncrackableP@$$12' /active:yes

Write-Host "[+] Defender and firewall has been disabled."
Write-Host "[+] User Adrian is now part of the Remote Desktop Group"
Write-Host "[+] RDP has been enabled"
Write-Host "[!] Assign user Adrian SeImpersonatePrivilege manually"
Write-Host '[+] Admin user has been active and password is:UncrackableP@$$12'
Write-Host '[!] Log-in as Administrator and run this on a powershell: runas.exe /u:Nicole /p:Ready4@ll! cmd.exe, to saved it in the Powershell History'