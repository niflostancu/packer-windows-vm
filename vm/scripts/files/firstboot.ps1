# First boot logging

# Logging
Start-Transcript -path "C:\Windows\vmfiles\vm-firstboot.log" -Append -force

# Make sure user does not expire
$localUser = [Environment]::Username
Get-WmiObject -Class Win32_UserAccount -Filter "name = '$localUser'" | Set-WmiInstance -Argument @{PasswordExpires = 0}

# Fix networking for WinRM
Powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden C:\Windows\vmfiles\fix-network.ps1

# Extend disk 
$extendvolume=@(
    'select volume 1',
    'extend',
    'exit'
)
$extendvolume | diskpart

# End logging
stop-transcript 

