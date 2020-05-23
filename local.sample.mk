# Local build variables
# Copy this as 'local.mk'

# Path to required ISO images
OS_INSTALL_ISO = $(HOME)/Downloads/SW_DVD5_WIN_ENT_LTSC_2019_64-bit_English_MLF_X21-96425.ISO
VIRTIO_INSTALL_ISO = $(HOME)/Downloads/virtio-win-0.1.141.iso

# packer's temporary directory to use (make sure you have >20GB free space!)
TMP_DIR=/tmp/packer

# the name of the libvirt storage pool (for virt_install)
LIBVIRT_POOL=vagrant
LIBVIRT_CONNECTION=qemu:///system

