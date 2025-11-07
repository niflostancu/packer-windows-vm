# & "C:\Windows\vmfiles\debloat\debloater.ps1"

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'
#no progressbars to slow down powershell transfers
$OrginalProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

Start-Transcript -Path "C:\Windows\vmfiles\vm-debloat.log"

Get-ChildItem "C:\Windows\vmfiles\debloat\" -Filter '*.ps1' | ForEach-Object {
	Write-Output "Running debloat: $_.FullName" | Out-Host
	& $_.FullName
}

#Set ProgressPreerence back
$ProgressPreference = $OrginalProgressPreference
Stop-Transcript

# Restart-Computer -Force
