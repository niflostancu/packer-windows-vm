# Install virtualization drivers
# Note: requires to be ran right before a packer `windows-restart` provisioner as workaround
# (this script will return early and stop WinRM, otherwise networking crashes during drivers
# install and packer errors)

# $global:DEBUG = $true
Invoke-VMRebootingTask -TaskID "provision_virtio" `
    -ScriptSnippet "& `"$VMSCRIPTS\files\provision-virtio.ps1`""

