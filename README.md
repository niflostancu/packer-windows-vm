# Packer scripts for building Windows VMs (qemu/libvirt)

## Features

* Build script optimized for QEmu / libvirt
* Automatically installs all Windows Updates available
* Includes [Chocolatey](https://chocolatey.org/) package manager
* [msys2](https://www.msys2.org/) with bash, sshd, git
* NFS client installed (for easy file sharing with host)
* Drivers installed: VirtIO, qemu-ga, Spice Guest Tools
* Various app tweaks (show hidden files, delete OneDrive etc.)
* Cleanup script for obtaining a smaller image at the end

Several notes:

* Inside msys, `C:\Users\developer` is mounted to `/home/developer`

## Building

Use the bundled `Makefile` for building the image.

Artifacts required beforehand:

- A Windows 10 .iso (you can grab [evaluation ones from 
  Microsoft](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise))
- [Virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/)

You will need to create a `variables.local.json` file defining the paths to the
ISOs (and any other Packer variables you might want to change):
```
{
	"iso_url": "/path/to/windows10.iso",
	"virtio_win_iso": "/path/to/virtio-win.iso",
	"arch": "amd64"
}
```

Afterwards, `make base` to build the base Windows 10 image, then `make fullvm`
to install all apps/packages the on top of the base layer.

The Packer's temporary directory defaults to `~/.cache/packer`. It can be overridden
using _BUILD_DIR_:
```
make BUILD_DIR=/path/to/tmp [targets]...
```

