# Brings Windows up to date.
#

Write-Output 'Installing PSWindowsUpdate...'
Install-PackageProvider -Name NuGet -Force | out-null
Install-Module -Name PSWindowsUpdate -Force | out-null
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false | out-null

Write-Output 'Enabling WindowsUpdate...'
sc.exe config wuauserv start= demand
sc.exe start wuauserv

# Set DeliveryOptimization to Internet
$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" 
New-Item -Path $regKey -Force | out-null
Set-ItemProperty -Path $RegKey -Name DODownloadMode -Type Dword -Value 3 | out-null

# Start the updates
Write-Output 'Updating Windows, this may take some time...'

Get-WUInstall -MicrosoftUpdate -AcceptAll -Download
Get-WUInstall -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot

Write-Output 'Deactivating WindowsUpdate...'

$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
New-Item $WindowsUpdatePath -Force | out-null
New-Item $AutoUpdatePath -Force | out-null
Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1 | out-null

# disable auto update
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" | Disable-ScheduledTask
takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R | out-null
icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T | out-null
Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" | Disable-ScheduledTask

