# Image cleanup & optimization script

$ErrorActionPreference = "Stop"

# Clean Windows startup image
dism.exe /online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase

# Disable Windows Update
sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

# Clean SoftwareDistribution directory with leftover updates
Remove-Item "$env:SystemRoot\SoftwareDistribution*" -Recurse -Force -ErrorAction SilentlyContinue

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
Optimize-DiskUsage

Get-PSDrive -PSProvider FileSystem

exit 0

