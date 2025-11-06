# Install virtualization drivers

shutdown /r /f /t 600 /c "will reboot after virtio drivers finished"

# Start a background process for installing virtio drivers that will reboot automatically when finished
#Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList powershell.exe, "C:\Windows\vmfiles\provision-virtio.ps1"

Start-Process -FilePath "powershell.exe" -ArgumentList "C:\Windows\vmfiles\provision-virtio.ps1"

