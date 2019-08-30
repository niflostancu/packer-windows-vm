# Tweaks the msys2 install
$ErrorActionPreference = "Stop"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
  [System.Environment]::GetEnvironmentVariable("Path","User") 

$msysRoot = "C:\tools\msys64"

## Install Msys tools (git, rsync, openssh)
& $msysRoot\usr\bin\pacman -S --noconfirm --needed git openssh cygrunsrv mingw-w64-x86_64-editrights rsync

# add mounts for user home and /vagrant (used by the default rsync)
New-Item -ItemType directory -Force -Path "$msysRoot\vagrant" | out-null
New-Item -ItemType directory -Force -Path "C:\users\vagrant\sync" | out-null

$fstab = (Get-Content -Path "$msysRoot\etc\fstab")
If (!($fstab -like "*/vagrant*")) {
	$fstab += "`nc:/Users/Vagrant /home/vagrant/ ntfs binary,posix=0,exec,user 0 0`n"
	$fstab += "c:/Users/Vagrant/sync /vagrant ntfs binary,posix=0,exec,user 0 0`n"
	Set-Content -Path "$msysRoot\etc\fstab" -Value $fstab | out-null
}

## Install vagrant ssh keys
New-Item -ItemType Directory -Force -Path "C:\\Users\\vagrant\\.ssh" | out-null
Invoke-WebRequest -Uri "https://raw.github.com/hashicorp/vagrant/master/keys/vagrant.pub" -Outfile "C:\\Users\\vagrant\\.ssh\\authorized_keys"

# Configure msys2 openssh to run as service
& $msysRoot\usr\bin\bash "C:\Windows\vmfiles\msys-sshd.sh"

## Add firewall exception
netsh advfirewall firewall add rule name=SSHPort dir=in action=allow protocol=TCP localport=22
netsh advfirewall firewall add rule name="MSyS sshd" dir=in action=allow program="$msysRoot\usr\bin\sshd.exe" enable=yes

