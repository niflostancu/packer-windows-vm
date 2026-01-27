# BoxStarter package to install windows updates

. "C:\Windows\vmscripts\common.ps1"

Write-Host "winupd: processing WindowsUpdate..."
Install-WindowsUpdate -AcceptEula

if (Test-PendingReboot) {
	Write-Host "winupd: Reboot requested..."
	Invoke-Reboot
	exit 0
}

Write-Host "winupd: Finished!"
Write-Host "winupd: Re-enabling WinRM..."
Restart-VMWinRM

