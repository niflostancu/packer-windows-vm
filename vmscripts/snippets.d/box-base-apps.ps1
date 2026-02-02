# Provision base apps
# Must be run as Scheduled Task using BoxStarter

# Enable developer mode on the system
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock `
    -Name AllowDevelopmentWithoutDevLicense -Value 1

# add NuGet & PSGallery (for Windows Terminal)
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Repair-WinGetPackageManager -Force -Latest

# Install Window Terminal
Write-BoxstarterMessage "Installing Windows Terminal"
winget install Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements

# Common tools
choco install -y notepadplusplus.install
choco install -y 7zip.install
choco install -y sysinternals

