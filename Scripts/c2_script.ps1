$FolderPath = "C:\Backups"
$ShareName = "Backups"
$UserName = "MYDOMAIN.COM\Nicol"   

# Ensure the folder exists
if (-not (Test-Path $FolderPath)) {
    New-Item -Path $FolderPath -ItemType Directory
}

# Remove existing share if exists (optional, to avoid conflicts)
if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Remove-SmbShare -Name $ShareName -Force
}

# Create SMB share with read-only access for Nicol
New-SmbShare -Name $ShareName -Path $FolderPath -ReadAccess $UserName
Write-Host "[+] SMB Folder has been created."
Write-Host "[+] Permissions for user Nicol has been added."

# Enabling local share to domain users

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$valueName = "AllowInsecureGuestAuth"
$valueData = 1

# Check if the value exists
if (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue) {
    # Value exists — update it to 1
    Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData
    Write-Host "[+] Enabling local share updated: $valueName to value $valueData"
} else {
    # Value does not exist — create it with value 1
    New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWORD -Force
    Write-Host "[+] Enabling local share created: $valueName with value $valueData"
}
# Copying zip file to SMBShare
Copy-Item -Path ".\images.zip" -Destination "C:\Backups"
Write-Host "[+] ZIP files has been moved to $FolderPath"
Write-Host "[+] All changes for this CLIENT are done!"