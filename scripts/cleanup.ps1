# Final image cleanup & optimization phase
#

$ErrorActionPreference = "Stop"

# Clean Windows startup image
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# Compact the windows installation
sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
Optimize-DiskUsage

