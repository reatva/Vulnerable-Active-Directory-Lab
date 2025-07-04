# Variables 
Import-Module GroupPolicy
$GPOName = "Lab - Disable Updates, Defender & Firewall"
$TargetOU = (Get-ADDomain).DistinguishedName  
$baseKey = "HKLM\Software\Policies\Microsoft\WindowsFirewall"
$DefaultUsersOU = "CN=Users,$TargetOU"

# Create GPO if it doesn't exist
$GPO = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue
if (-not $GPO) {
    Write-Host "Creating new GPO: $GPOName"
    $GPO = New-GPO -Name $GPOName
} else {
    Write-Host "GPO $GPOName already exists."
}

# Disable Automatic Updates
Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 1

# Disable Defender Antivirus
Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows Defender" -ValueName "DisableAntiSpyware" -Type DWord -Value 1
Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" -ValueName "DisableRealtimeMonitoring" -Type DWord -Value 1

#Disable Firewall
Set-GPRegistryValue -Name $GPOName -Key "$baseKey\DomainProfile" -ValueName "EnableFirewall" -Type DWord -Value 0
Set-GPRegistryValue -Name $GPOName -Key "$baseKey\PrivateProfile" -ValueName "EnableFirewall" -Type DWord -Value 0
Set-GPRegistryValue -Name $GPOName -Key "$baseKey\PublicProfile" -ValueName "EnableFirewall" -Type DWord -Value 0

# Link the GPO if not already linked
$links = Get-GPInheritance -Target $TargetOU
$linkedGPOs = $links.GpoLinks | Select-Object -ExpandProperty DisplayName
if ($linkedGPOs -notcontains $GPOName) {
    Write-Host "Linking GPO $GPOName to $TargetOU"
    New-GPLink -Name $GPOName -Target $TargetOU
} else {
    Write-Host "GPO $GPOName is already linked to $TargetOU"
}

# Define a list of user/password pairs as hashtables or custom objects
$UserList = @(
    @{User="adrian"; Password='Not4@ver3ge!'},
    @{User="lucy"; Password='$monique$1991$'},
    @{User="nicol"; Password='Ready4@ll!'},
    @{User="svc_iis"; Password='!giSem@89$gSm'},
    @{User="emmet"; Password='!giN0t1Nr0oCKu!'}
)

# Loop through each pair
foreach ($Item in $UserList) {
    $User = $Item.User
    $Password = $Item.Password
    $PasswordSecure = ConvertTo-SecureString $Password -AsPlainText -Force
    New-ADUser -Name $User -SamAccountName $User -AccountPassword $PasswordSecure -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false -Path $DefaultUsersOU

}

# ASREProastable
Set-ADUser lucy -Replace @{
    userAccountControl = (
        (Get-ADUser lucy -Properties userAccountControl).userAccountControl -bor 4194304
    )
}

# Kerberoastable user
Set-ADUser -Identity "svc_iis" -ServicePrincipalNames @{Add="HTTP/webserver.mydomain.com"}
setspn -l svc_iis

# Bloodhound Reset Password for svc_iis
dsacls "CN=emmet,CN=Users,DC=mydomain,DC=com" /G "mydomain.com\svc_iis:CA;Reset Password"

# DCSync for emmet
dsacls $TargetOU /G "mydomain.com\emmet:CA;Replicating Directory Changes"
dsacls $TargetOU /G "mydomain.com\emmet:CA;Replicating Directory Changes All"

# Creating Security Group and adding Nicol
New-ADGroup -Name "LDAP_Deny_Group" -GroupScope Global -GroupCategory Security -Path $DefaultUsersOU; Add-ADGroupMember -Identity "LDAP_Deny_Group" -Members nicol, adrian

# GPO
$GPOName = "Deny LDAP Access"
New-GPO -Name $GPOName  #Creates GPO

Write-Host "GPO configuration complete. Run 'gpupdate /force' on clients to apply."
Write-Output "[+] User $User has been created."
Write-Output "[+] User Lucy is now ASREProastable."
Write-Output "[+] User svc_iis is now Kerberoastable."
Write-Host "[+] User svc_iis can now reset user emmet password."
Write-Host "[+] User emmet can now do a DCSync on the Domain Controller."
Write-Host "[+] Security Group & GPO created successfully"
Write-Host "[!] Restric queris manually.Do not forget to link the GPO!"
