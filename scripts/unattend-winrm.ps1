# Installs & Configures WinRM for Vagrant / PackerIO communication
#

$ErrorActionPreference = "Stop"

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# Set network to private
Set-NetConnectionProfile -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex -NetworkCategory Private | out-null

# Set up WinRM and configure some things
Set-WSManQuickConfig -Force | out-null
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value True | out-null
Set-Item WSMan:\localhost\Service\Auth\Basic -Value True | out-null
Set-Service WinRM -StartupType Automatic | out-null
Restart-Service winrm | out-null

Set-ExecutionPolicy Unrestricted -Force

