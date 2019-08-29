# Windows Tweaks / optimizations
#

# Unrestricted execution
Set-ExecutionPolicy Unrestricted -Force

# Install some powershell goodies
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name 'WindowsBox.Compact'

# Add the fix-network.ps1 script to Startup
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden C:\Windows\vmfiles\fix-network.ps1'
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "FixNetwork" `
  -Description "Sets Networks to Private"

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

# Do some tweaks
Disable-ScheduledTask -TaskName 'ScheduledDefrag' -TaskPath '\Microsoft\Windows\Defrag' | out-null

# Disable unused services
$services = @(
  "diagnosticshub.standardcollector.service"
  "DiagTrack"               # Diagnostics Tracking Service
  # "dmwappushservice"      # WAP Push Message Routing Service (see known issues)
  "HomeGroupListener"       # HomeGroup Listener
  "HomeGroupProvider"       # HomeGroup Provider
  "lfsvc"                   # Geolocation Service
  "MapsBroker"              # Downloaded Maps Manager
  "NetTcpPortSharing"       # Net.Tcp Port Sharing Service
  "RemoteRegistry"          # Remote Registry
  "SharedAccess"            # Internet Connection Sharing (ICS)
  "TrkWks"                  # Distributed Link Tracking Client
  "WbioSrvc"                # Windows Biometric Service
  "WlanSvc"                 # WLAN AutoConfig
  "WMPNetworkSvc"           # Windows Media Player Network Sharing Service
  "wscsvc"                  # Windows Security Center Service
  "WSearch"                 # Windows Search
  "XblAuthManager"          # Xbox Live Auth Manager
  "XblGameSave"             # Xbox Live Game Save Service
  "XboxNetApiSvc"           # Xbox Live Networking Service
)

Write-Output "Disabling services..."
foreach ($service in $services) {
  Get-Service -Name $service | Set-Service -StartupType Disabled
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

# Remove OneDrive please
Write-Output "Removing OneDrive"
taskkill.exe /F /IM "OneDrive.exe"
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

Write-Output "Removing OneDrive leftovers"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive" | out-null
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive" | out-null
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp" | out-null
# check if directory is empty before removing:
If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive" | out-null
}

Write-Output "Removing run hook for new users"
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT" | out-null
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f | out-null
reg unload "hku\Default" | out-null

