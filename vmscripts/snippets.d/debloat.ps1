# no errors throughout
$ErrorActionPreference = 'Continue'
# no progressbars to slow down powershell transfers
$OrginalProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

Start-Transcript -Path "$VMSCRIPTS\vm-debloat.log"

Get-ChildItem "$VMSCRIPTS\snippets.d\debloat\" -Filter '*.ps1' | ForEach-Object {
	Write-Output "Running debloat: $_.FullName" | Out-Host
	& $_.FullName
}

#Set ProgressPreerence back
$ProgressPreference = $OrginalProgressPreference
Stop-Transcript

# Restart-Computer -Force
