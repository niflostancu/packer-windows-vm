# Permanently disabled Windows Update
# Ref: https://stackoverflow.com/questions/44555223/turn-off-windows-update-service-auto-updates-windows-10-using-powershell

# we need psexec...
$psToolsURL = 'https://download.sysinternals.com/files/PSTools.zip'
$tempZip = '{0}_PsTools.zip' -f [System.IO.Path]::GetTempFileName()
$tempExe = Join-Path -Path $env:TEMP -ChildPath 'PsExec.exe'
$psToolsDir = Join-Path -Path $env:TEMP -ChildPath "PsTools"
New-Item -ItemType Directory -Force -Path "$psToolsDir"
Write-Verbose "Dowloading PsTools from $psToolsURL to $tempZip ..."
Invoke-WebRequest -Uri $psToolsURL -OutFile $tempZip
Unblock-File -Path $tempZip
Expand-Archive -LiteralPath $tempZip -DestinationPath $psToolsDir
Remove-Item -Path $tempZip -Force
$psExec = Join-Path -Path $psToolsDir -ChildPath 'PsExec.exe'

Write-Output 'Deactivating WindowsUpdate...'

$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

New-Item $WindowsUpdatePath -Force | out-null
New-Item $AutoUpdatePath -Force | out-null

Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1 | out-null
takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R | out-null
icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T | out-null
& $psExec -AcceptEula -i -d -s powershell.exe -Command "Get-ScheduledTask -TaskPath `"\Microsoft\Windows\WindowsUpdate\`" | Disable-ScheduledTask"
& $psExec -AcceptEula -i -d -s powershell.exe -Command "Get-ScheduledTask -TaskPath `"\Microsoft\Windows\UpdateOrchestrator\`" | Disable-ScheduledTask"

# Disable Windows Update Server AutoStartup
Set-Service wuauserv -StartupType Disabled
sc.exe config wuauserv start=disabled 
# Disable Windows Update Running Service
Stop-Service wuauserv 
sc.exe stop wuauserv 
# Check Windows Update Service state
sc.exe query wuauserv | findstr "STATE"

