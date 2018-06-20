#
# Brings Windows up to date.
#

Write-Output 'Installing PSWindowsUpdate...'
Install-PackageProvider -Name NuGet -Force | out-null
Install-Module -Name PSWindowsUpdate -Force | out-null
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false | out-null

# Set DeliveryOptimization to Internet
$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" 
New-Item -Path $regKey -Force | out-null
Set-ItemProperty -Path $RegKey -Name DODownloadMode -Type Dword -Value 3 | out-null

# Start the updates
Write-Output 'Updating Windows, this may take some time...'

Get-WUInstall -MicrosoftUpdate -AcceptAll -Download
Get-WUInstall -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot

