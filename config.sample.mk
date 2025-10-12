# Local build variables
# Copy this as 'config.local.mk'
#
# also check out framework/config.default.mk for all variables.

# Path to required ISO images
WIN10_INSTALL_ISO = $(HOME)/Downloads/Win10_22H2_EnglishInternational_x64v1.iso
VIRTIO_INSTALL_ISO = $(lastword $(wildcard $(HOME)/Downloads/virtio-win-*.iso))

# E.g., move build output (VM destination) directory to an external drive
#BUILD_DIR ?= /media/myssd/tmp/packer

# InstallFrom index, set to 1 for LTSC, leave empty for others
WIN10_INSTALL_FROM_IDX = 
# Product Key, take it from:
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
WIN10_PRODUCT_KEY = NPPR9-FWDCX-D2C8J-H872K-2YT43
# installer language (note: use en-GB for English International)
WIN_INSTALL_LANGUAGE = "en-GB"

# Prevent running Windows Update (on the full vm layer)
#NO_UPGRADE = 1

