# Local build variables for custom example Windows VM
# Copy this as 'config.local.mk'

# VM Edition ;) 
APP_VM_VERSION = 2025

# REQUIRED: you must manually clone the packer-windows-vm repository at:
# https://github.com/niflostancu/packer-windows-vm
# after that, enter its path here (may be relative):
WIN_PKR_SCRIPTS_DIR = ../../

# Path to the pre-built Windows base image
WIN_PKT_BASE_IMAGE = $(BUILD_DIR)/Win_10_base/Win_10_base.qcow2

