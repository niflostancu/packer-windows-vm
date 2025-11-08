# Windows package managers installation

$ErrorActionPreference = "Stop"

Write-Output "Installing NuGet & WinGet..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Repair-WinGetPackageManager -Force -Latest

Write-Output "Installing PSGallery tools..."
# Install some powershell goodies
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# used by the cleanup script
Install-Module -Name 'WindowsBox.Compact' -Repository PSGallery -Force

Write-Output "Installing Chocolatey..."
# Install Chocolatey (Windows Package Manager)
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Import some useful chocolatey modules
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

# Install Boxstarter (used for running provisioning scripts)
choco install --no-progress -r -y Boxstarter

