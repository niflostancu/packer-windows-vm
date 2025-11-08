# Install virtualization drivers
# Note: requires to be ran right before a packer `windows-restart` provisioner as workaround
# (this script will return early and stop WinRM, otherwise networking crashes during drivers
# install and packer errors)

shutdown /r /f /t 600 /c "will reboot after virtio drivers finished"

# Start a background process for installing virtio drivers that will reboot automatically when finished
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "$VMSCRIPTS\files\provision-virtio.ps1"

