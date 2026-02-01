# Image cleanup & optimization script
# @RunAsTask true

$ErrorActionPreference = "Stop"

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
while (Get-Process -Name @("cleanmgr","dismhost") -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

# Clean Windows startup image
dism.exe /online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase
while (Get-Process -Name @("dismhost") -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

# Disable Windows Update
sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

$localTemp = [Environment]::GetFolderPath('LocalApplicationData') + "\Temp"
Remove-Item "$localTemp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean SoftwareDistribution directory with leftover updates
Remove-Item "$env:SystemRoot\SoftwareDistribution*" -Recurse -Force -ErrorAction SilentlyContinue

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
Optimize-DiskUsage

Get-PSDrive -PSProvider FileSystem

