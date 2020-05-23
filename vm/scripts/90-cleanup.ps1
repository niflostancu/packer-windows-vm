# Final image cleanup & optimization phase
#

$ErrorActionPreference = "Stop"

# Clean Windows startup image
dism.exe /online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase

# Disable Windows Update
sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

# From: https://github.com/windowsbox/powershellmodules (WindowsBox.Compact)
# Optimize-DiskUsage

exit 0

