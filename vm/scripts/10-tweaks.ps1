# Windows VM Tweaks / optimizations

# Unrestricted execution
Set-ExecutionPolicy Unrestricted -Scope Process -Force
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
# Get-ExecutionPolicy -List

# Install some powershell goodies
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name 'WindowsBox.Compact' -Repository PSGallery -Force

# Add the fix-network.ps1 script to Startup
# (for when the virtualized net adapter changes)
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden C:\Windows\vmfiles\fix-network.ps1'
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "FixNetwork" `
  -Description "Sets Networks to Private" | out-null
Write-Output "FixNetwork task registered!"

# configure powersaving and screen saver
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c # High Performance
powercfg -change -monitor-timeout-ac 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HiberFileSizePercent -value 0 | out-null
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -name HibernateEnabled -value 0 | out-null
powercfg -hibernate OFF
New-Itemproperty -Path "registry::HKCU\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -PropertyType "DWord" -Force | out-null
New-Itemproperty -Path "registry::HKCU\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 0 -PropertyType "DWord" -Force | out-null
New-Itemproperty -Path "registry::HKU\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -PropertyType "DWord" -Force | out-null
New-Itemproperty -Path "registry::HKU\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 0 -PropertyType "DWord" -Force | out-null

# Disable automatic pagefile management
$cs = gwmi Win32_ComputerSystem
if ($cs.AutomaticManagedPagefile) {
    $cs.AutomaticManagedPagefile = $False
    $cs.Put()
}

# Disable a single pagefile if any
$pg = gwmi win32_pagefilesetting
if ($pg) {
    $pg.Delete()
}

# Configure Windows Explorer properties
Write-Output "Tweaking explorer"
$explorer_key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
# Show file extensions
Set-ItemProperty $explorer_key\Advanced\ -name HideFileExt -value 0
# Show hidden files
Set-ItemProperty $explorer_key\Advanced\ -name Hidden -value 1
# Show Run command in Start Menu
Set-ItemProperty $explorer_key\Advanced\ -name Start_ShowRun -value 1
# Show Administrative Tools in Start Menu
Set-ItemProperty $explorer_key\Advanced\ -name StartMenuAdminTools -value 1
# Enable QuickEdit mode
Set-ItemProperty HKCU:\Console\ -name QuickEdit -value 1
# Show "Computer" desktop icon"
$key = "$explorer_key\HideDesktopIcons\NewStartPanel"
New-Item $key -Force | out-null
New-ItemProperty "$key" "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -PropertyType dword -Value 0 -Force | out-null
