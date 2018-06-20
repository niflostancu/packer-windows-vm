# Software installation
$ErrorActionPreference = "Stop"

# Enable the Windows NFS client
Enable-WindowsOptionalFeature -Online -FeatureName ClientForNFS-Infrastructure -All | out-null
Enable-WindowsOptionalFeature -Online -FeatureName NFS-Administration -All | out-null

# Install Chocolatey (Windows Package Manager)
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Import some useful chocolatey modules
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

# Install msys2
choco install --force -r -y msys2
Update-SessionEnvironment
Install-ChocolateyPath "C:\tools\msys64\usr\bin" -PathType 'Machine'

