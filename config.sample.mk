# Local build variables
# Copy this as 'config.local.mk'
#
# also check out framework/config.default.mk for all variables.

# Path to required ISO images
WIN10_INSTALL_ISO = $(HOME)/Downloads/SW_DVD5_WIN_ENT_LTSC_2019_64-bit_English_MLF_X21-96425.ISO
VIRTIO_INSTALL_ISO = $(HOME)/Downloads/virtio-win-0.1.262.iso

# InstallFrom index, set to 1 for LTSC, leave empty for others
WIN10_INSTALL_FROM_IDX = 
# Product Key, take it from:
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
WIN10_PRODUCT_KEY = NPPR9-FWDCX-D2C8J-H872K-2YT43

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

# the name of the libvirt storage pool (for virt_install)
LIBVIRT_POOL=vagrant
LIBVIRT_CONNECTION=qemu:///session

