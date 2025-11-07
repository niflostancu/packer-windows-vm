# Windows package managers installation

$ErrorActionPreference = "Stop"

Write-Output "Installing Chocolatey..."
# Install Chocolatey (Windows Package Manager)
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Import some useful chocolatey modules
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

# Install Boxstarter (used for running provisioning scripts)
choco install --no-progress -r -y Boxstarter

