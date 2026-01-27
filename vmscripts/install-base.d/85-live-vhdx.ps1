# Quick tweaks to enable live booting using Ventoy and VHDX images

# Leave virtio on
reg add "HKLM\SYSTEM\CurrentControlSet\Services\viostor" /v Start /t REG_DWORD /d 0 /f

# Enable USB storage
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbstor" /v Start /t REG_DWORD /d 0 /f

# Enable generic SATA/AHCI
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci" /v Start /t REG_DWORD /d 0 /f

# Enable generic IDE
reg add "HKLM\SYSTEM\CurrentControlSet\Services\pciide" /v Start /t REG_DWORD /d 0 /f

# prevent VHD expansion at boot
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FsDepends\Parameters" `
	/v VirtualDiskExpandOnMount /t REG_DWORD /d 4 /f

# finally, enable boot log
bcdedit /set '{bootmgr}' displaybootmenu yes
bcdedit /set '{bootmgr}' timeout 5
bcdedit /set '{current}' bootlog Yes

