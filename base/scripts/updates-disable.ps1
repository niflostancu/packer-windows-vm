# Permanently disabled Windows Update

Write-Output 'Deactivating WindowsUpdate...'

$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

New-Item $WindowsUpdatePath -Force | out-null
New-Item $AutoUpdatePath -Force | out-null

Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1 | out-null
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" | Disable-ScheduledTask
takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R | out-null
icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T | out-null
Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" | Disable-ScheduledTask

# Disable Windows Update Server AutoStartup
Set-Service wuauserv -StartupType Disabled
sc.exe config wuauserv start=disabled 
# Disable Windows Update Running Service
Stop-Service wuauserv 
sc.exe stop wuauserv 
# Check Windows Update Service state
sc.exe query wuauserv | findstr "STATE"

