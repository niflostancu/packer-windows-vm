# Separate script to provision WinGet apps using Boxstarter & Scheduled Task

Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Repair-WinGetPackageManager -Force -Latest

# Install Window Terminal
Write-BoxstarterMessage "Installing Windows Terminal"
winget install Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements

# old version (workaround for old wingets):
#winget install 9N0DX20HK701 --source msstore --silent --accept-source-agreements --accept-package-agreements

