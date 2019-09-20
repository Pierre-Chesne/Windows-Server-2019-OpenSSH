# Script d'installation "OpenSSH Server" pour Windows Server 2019
# Authentification par cle publique
# Auteurs Pascal Sauliere et Pierre Chesne

param( 
[parameter(Mandatory=$true)]
[string]
$key
)

# Installation OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Demarage du serveur Open SSH
Start-Service sshd

# Demarage Automatique du server Open SSH
Set-Service -Name sshd -StartupType 'Automatic'

# Shell "PowerShell" par defaut
New-ItemProperty `
  -Path "HKLM:\SOFTWARE\OpenSSH" `
  -Name DefaultShell `
  -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -PropertyType String -Force

# Creation du repertoire .ssh
New-Item -Path {env:USERPROFILE}\.ssh -ItemType Directory

# Copie de la cle publique
Add-Content {env:USERPROFILE}\.ssh\authorized_keys $key

# Parametrage du fichier sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('#PubkeyAuthentication yes' , 'PubkeyAuthentication yes') | Set-Content C:\ProgramData\ssh\sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys' , '#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content C:\ProgramData\ssh\sshd_config
(Get-Content C:\ProgramData\ssh\sshd_config).Replace('Match Group administrators' , '#Match Group administrators') | Set-Content C:\ProgramData\ssh\sshd_config

# Redemarrage du service OpenSSH
Restart-Service sshd
