# Install & configure msys2

$ErrorActionPreference = "Stop"

# Chocolatey will install msys2 at ToolsLocation
$msysRoot = "C:\tools\msys64"
choco install --no-progress -r -y msys2

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
  [System.Environment]::GetEnvironmentVariable("Path","User") 

$msys2 = "$msysRoot\msys2_shell.cmd"
$msys2Args = @("-defterm", "-no-start", "-msys2", "-c", "`"$@`"", "--")

## Install Msys tools (git, rsync, openssh)
& $msys2 $msys2Args pacman -S --noconfirm --needed `
	git openssh cygrunsrv mingw-w64-x86_64-editrights rsync

# add mounts for user home and /share (used by the default rsync)
$localUser = [Environment]::Username
New-Item -ItemType directory -Force -Path "$msysRoot\share" | out-null
New-Item -ItemType directory -Force -Path "C:\users\$localUser\sync" | out-null

$fstab = (Get-Content -Path "$msysRoot\etc\fstab")
If (!($fstab -like "*/share*")) {
	$fstab += "`nc:/Users/$localUser /home/$localUser/ ntfs binary,posix=0,exec,user 0 0`n"
	$fstab += "c:/Users/$localUser/sync /share ntfs binary,posix=0,exec,user 0 0`n"
	Set-Content -Path "$msysRoot\etc\fstab" -Value $fstab | out-null
}

## Install Vagrant ssh keys (FIXME: add option for custom authorized keys)
New-Item -ItemType Directory -Force -Path "C:\\Users\\$localUser\\.ssh" | out-null
Invoke-WebRequest -Uri "https://raw.github.com/hashicorp/vagrant/master/keys/vagrant.pub" `
	-Outfile "C:\\Users\\$localUser\\.ssh\\authorized_keys"

# Configure msys2 openssh to run as service
& $msys2 "$VMSCRIPTS\files\msys-sshd.sh"

## Add firewall exception
netsh advfirewall firewall add rule name=SSHPort dir=in action=allow protocol=TCP localport=22
netsh advfirewall firewall add rule name="MSyS sshd" dir=in action=allow program="$msysRoot\usr\bin\sshd.exe" enable=yes

exit 0

