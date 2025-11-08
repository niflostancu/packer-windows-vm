# Brings Windows up to date.

# Set DeliveryOptimization to Internet
$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" 
New-Item -Path $regKey -Force | out-null
Set-ItemProperty -Path $RegKey -Name DODownloadMode -Type Dword -Value 3 | out-null

# Start the updates
Write-Output 'Updating Windows, this may take some time...'

Install-BoxstarterPackage -PackageName "$VMSCRIPTS\snippets.d\box-win-update.ps1"

