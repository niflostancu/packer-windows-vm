# Local build variables
# Copy this as 'config.local.mk'
#
# also check out framework/config.default.mk for all variables.

# Path to required ISO images
WIN10_INSTALL_ISO = $(HOME)/Downloads/SW_DVD5_WIN_ENT_LTSC_2019_64-bit_English_MLF_X21-96425.ISO
VIRTIO_INSTALL_ISO = $(HOME)/Downloads/virtio-win-0.1.262.iso

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

# the name of the libvirt storage pool (for virt_install)
LIBVIRT_POOL=vagrant
LIBVIRT_CONNECTION=qemu:///session

