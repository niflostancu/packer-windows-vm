# Image cleanup & optimization script
# @RunAsTask true

$ErrorActionPreference = "Stop"

choco install --no-progress -y sdelete

# Run disk cleanup utility
$cleanupKeys = @(
    "Active Setup Temp Folders",
    "BranchCache",
    "Delivery Optimization Files",
    "Diagnostic Data Viewer database files",
    "Downloaded Program Files",
    "Internet Cache Files",
    "Offline Pages Files",
    "Old ChkDsk Files",
    "Previous Installations",
    "Recycle Bin",
    "RetailDemo Offline Content",
    "Service Pack Cleanup",
    "Setup Log Files",
    "System error memory dump files",
    "System error minidump files",
    "Temporary Files",
    "Temporary Setup Files",
    "Thumbnail Cache",
    "Update Cleanup",
    "Upgrade Discarded Files",
    "User file versions",
    "Windows Defender",
    "Windows Error Reporting Files",
    "Windows ESD installation files",
    "Windows Upgrade Log Files"
)
$volumeCachesPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
foreach ($key in $cleanupKeys) {
    $keyPath = Join-Path $volumeCachesPath $key
    if (Test-Path $keyPath) {
        Set-ItemProperty -Path $keyPath -Name StateFlags0100 -Value 2 -ErrorAction SilentlyContinue
    }
}
CleanMgr.exe /sagerun:100 /verylowdisk
# wait neccesary as CleanMgr.exe spins off separate processes...
$deadline = (Get-Date).AddSeconds(600)
do { Start-Sleep -Seconds 1 }
while ((Get-Process -Name @("cleanmgr", "dismhost") -EA SilentlyContinue) `
    -and (Get-Date) -lt $deadline)
if (Get-Process -Name @("cleanmgr", "dismhost") -EA SilentlyContinue) {
    Stop-Process -Name cleanmgr -Force -ErrorAction SilentlyContinue
}

# Clean Windows startup image
dism.exe /online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase
$deadline = (Get-Date).AddSeconds(600)
do { Start-Sleep -Seconds 1 }
while ((Get-Process -Name @("dismhost") -EA SilentlyContinue) `
    -and (Get-Date) -lt $deadline)
if (Get-Process -Name @("dismhost") -EA SilentlyContinue) {
    Stop-Process -Name cleanmgr -Force -ErrorAction SilentlyContinue
}

# Disable Windows Update
sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

$localTemp = [Environment]::GetFolderPath('LocalApplicationData') + "\Temp"
Remove-Item "$localTemp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean SoftwareDistribution directory with leftover updates
Remove-Item "$env:SystemRoot\SoftwareDistribution*" -Recurse -Force -ErrorAction SilentlyContinue

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
Write-Output "Cleaning Windows Update Files"
Remove-Item "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue
mkdir -Force C:\Windows\SoftwareDistribution\Download

Write-Output "Cleaning Temp Files"
try {
    Takeown /d Y /R /f "C:\Windows\Temp\*"
    Icacls "C:\Windows\Temp\*" /GRANT:r administrators:F /T /c /q  2>&1
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Logs" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\inetpub" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\PerfLogs" -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Output 'Failed to remove some temp files'
}
Write-Output "Removing Chocolatey cache..."
choco cache remove -y -f

Write-Output "Defragging C: Drive"
Optimize-Volume -DriveLetter C

# Note: this is veeery slow on qemu with discard unmap
#Optimize-DiskUsage
#Write-Output "Zeroing out disk space..."
#sdelete -z C:

Get-PSDrive -PSProvider FileSystem

