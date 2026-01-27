# Runs sysprep to generalize the machine

. "$PSScriptRoot\..\common.ps1"

Remove-Item -ErrorAction Ignore "$VMSCRIPTS\Logs\vm-firstboot.log"

& "C:/windows/System32/Sysprep/sysprep.exe" /oobe /generalize /quit /unattend:"$VMSCRIPTS\files\sysprep-unattend.xml"

# sysprep goes in background, wait for it to finish...
while (Get-Process -Name "sysprep" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

