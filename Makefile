## Top-level makefile for Windows VM gen
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk

# set default goals
DEFAULT_GOAL = main
INIT_GOAL = main

# custom variables
NOINSTALL ?=
PACKER_ARGS_EXTRA = $(call _packer_var,vm_no_upgrade,$(NO_UPGRADE))
PACKER_ARGS_EXTRA +=$(call _packer_var,virtio_win_iso,$(VIRTIO_INSTALL_ISO))
SUDO ?= sudo

win-ver = 10_LTSC
basevm-name = Win_$(win-ver)_base
basevm-packer-src = ./base
basevm-src-image = $(WIN10_INSTALL_ISO)

# VM with RL lab customizations
main-name = Win_$(win-ver)_main
main-packer-src = ./vm
main-src-from = basevm

define main-extra-rules=
.PHONY: cloud
cloud:
	qemu-img convert -O qcow2 "$$(main-dest-image)" "$$(main-dest-image).compact.qcow2"
	ls -lh "$$(main-dest-image)"
endef

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms += basevm main

$(call eval_common_rules)
$(call eval_all_vm_rules)

