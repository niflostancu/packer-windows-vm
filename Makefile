## Top-level makefile for Windows VM gen
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk

# set default goals
DEFAULT_GOAL = fullvm
INIT_GOAL = fullvm

# custom variables
VM_USER ?= developer
VM_PASSWORD ?= developer
NO_UPGRADE ?= 0
PACKER_ARGS_EXTRA =  $(call _packer_var,vm_no_upgrade,$(NO_UPGRADE))
PACKER_ARGS_EXTRA += $(call _packer_var,virtio_win_iso,$(VIRTIO_INSTALL_ISO))
PACKER_ARGS_EXTRA += $(call _packer_var,vm_user,$(VM_USER))
PACKER_ARGS_EXTRA += $(call _packer_var,vm_password,$(VM_PASSWORD))
SUDO ?= sudo

win-ver = 10
base-name = Win_$(win-ver)_base
base-packer-src = ./base
base-src-image = $(WIN10_INSTALL_ISO)
base-packer-args +=$(call _packer_var,install_from_idx,$(WIN10_INSTALL_FROM_IDX))
base-packer-args +=$(call _packer_var,product_key,$(WIN10_PRODUCT_KEY))
base-packer-args +=$(call _packer_var,install_language,$(WIN_INSTALL_LANGUAGE))

# VM with RL lab customizations
fullvm-name = Win_$(win-ver)_main
fullvm-packer-src = ./vm
fullvm-src-from = base

define fullvm-extra-rules=
.PHONY: cloud
cloud:
	qemu-img convert -O qcow2 "$$(fullvm-dest-image)" "$$(fullvm-dest-image).compact.qcow2"
	ls -lh "$$(fullvm-dest-image)*"
endef

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms += base fullvm

$(call eval_common_rules)
$(call eval_all_vm_rules)

