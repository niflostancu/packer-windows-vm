# First boot initialization

# Logging
Start-Transcript -path "$VMSCRIPTS\Logs\vm-firstboot.log" -Append -force

# Make sure user does not expire
$localUser = [Environment]::Username
Get-WmiObject -Class Win32_UserAccount -Filter "name = '$localUser'" | Set-WmiInstance -Argument @{PasswordExpires = 0}
Write-Output "Removed expiration for local user $localUser"

# Fix networking for WinRM
# Add the fix-network.ps1 script to Startup (for when the virt net adapter changes)
if (-Not (Get-ScheduledTask -TaskName "FixNetwork" -ErrorAction SilentlyContinue)) {
  $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden `"$VMSCRIPTS\files\vm-fix-network.ps1`""
  $trigger = New-ScheduledTaskTrigger -AtLogOn
  Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "FixNetwork" `
    -Description "Sets Networks to Private" | out-null
  Write-Output "FixNetwork task registered!"
}

# Warning: do not run while Packer is connected to WinRM!
#Powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden "$VMSCRIPTS\files\vm-fix-network.ps1"

# Extend disk 
$size = Get-PartitionSupportedSize -DriveLetter C
Resize-Partition -DriveLetter C -Size $size.SizeMax -ErrorAction Continue

# End logging
stop-transcript 

