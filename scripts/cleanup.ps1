# Final image cleanup & optimization phase
#

$ErrorActionPreference = "Stop"

# Clean Windows startup image
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# Compact the windows installation
Stop-Service wuauserv

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
Optimize-DiskUsage

