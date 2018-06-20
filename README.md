# Packer / Vagrant scripts for building Windows 10 Enterprise (libvirt)

## Features

* Build script optimized for QEmu / libvirt
* Automatically installs all Windows Updates available
* Supports `vagrant ssh` with a bash shell
* Supports `vagrant rsync`
* NFS client installed
* Includes [Chocolatey](https://chocolatey.org/) package manager
* [msys2](https://www.msys2.org/) with bash, sshd, git
* Drivers installed: VirtIO, qemu-ga, Spice Guest Tools
* Various app tweaks (show hidden files, delete OneDrive etc.)
* Cleanup script for obtaining a smaller image at the end

Several notes:

* Inside msys, `C:\Users\vagrant` is mounted to `/home/vagrant`
* `vagrant ssh` launches msys `bash` by default
* `vagrant rsync` uses `/c/...` syntax for cygwin paths

## Building

Use the bundled `Makefile` for building the image.

Artifacts required beforehand:

- A Windows 10 .iso (you can grab [evaluation ones from Microsoft](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise))
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

Afterwards, `make win10_x64` to build the image, `make install_win10_x64` to
install the box to Vagrant.

The Packer's temporary directory defaults to `/tmp/packer`. It can be overridden
using _TMP_DIR_:
```
make TMP_DIR=/path/to/tmp [targets]...
```

If the build fails after a long time (e.g. after Windows Update) and you don't
wish to lose your progress, set the _REUSE_IMAGE_ make variable, e.g.:
```
make REUSE_IMAGE=1
```

