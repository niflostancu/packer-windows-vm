## Top-level makefile for Windows VM gen
##

FRAMEWORK_DIR ?= ./framework
include $(FRAMEWORK_DIR)/framework.mk

# load modules
include $(FRAMEWORK_DIR)/lib/arch.mk
include $(FRAMEWORK_DIR)/lib/gen_vm_combo.mk
include $(FRAMEWORK_DIR)/lib/zerofree.mk

# set default goals
DEFAULT_GOAL = fullvm
INIT_GOAL = fullvm

VM_USER = developer
VM_PASSWORD = developer

# custom variables
NO_UPGRADE ?= 0
NO_PROVISION ?= 0
DO_SYSPREP ?= 0
DISK_SIZE ?= 35840
WIN10_INSTALL_FROM_IDX ?= 
WIN_INSTALL_LANGUAGE ?= $(strip $(if $(findstring EnglishInternational,$(WIN10_INSTALL_ISO)),en-GB,en-US))
PACKER_ARGS_EXTRA =  $(call _packer_var,vm_no_upgrade,$(NO_UPGRADE))
SUDO ?= sudo

WIN_VERSION ?= 10
winverstr = $(WIN_VERSION)$(if $(ARCH_USE_EFI),_EFI)
base-name = Win_$(winverstr)_base
base-packer-src = ./base
base-src-image = $(WIN10_INSTALL_ISO)
base-packer-args += $(call _packer_var,disk_size,$(DISK_SIZE))
base-packer-args += $(call _packer_var,extra_iso,$(VIRTIO_INSTALL_ISO))
base-packer-args +=$(call _packer_var,install_from_idx,$(WIN10_INSTALL_FROM_IDX))
base-packer-args +=$(call _packer_var,product_key,$(WIN10_PRODUCT_KEY))
base-packer-args +=$(call _packer_var,install_language,$(WIN_INSTALL_LANGUAGE))
base-packer-args += $(call _packer_var,vm_no_provision,$(NO_PROVISION))
base-packer-args += $(call _packer_var,vm_do_sysprep,$(DO_SYSPREP))

define vhdx_convert_rule=
.PHONY: $(vm)_vhdx
$(vm)_vhdx:
	qemu-img convert -f qcow2 -O vhdx "$$($(vm)-dest-image)" "$$($(vm)-dest-image:%.qcow2=%.vhdx)"

endef
base-extra-rules += $(vhdx_convert_rule)

# Fully-customized VM (for development)
fullvm-name = Win_$(winverstr)_full
fullvm-packer-src = ./generic
fullvm-src-from = base
fullvm-packer-args += $(call _packer_var,vm_no_provision,$(NO_PROVISION))
fullvm-packer-args += $(call _packer_var,vm_install_tasks,install-fullvm.d/)

define fullvm-extra-rules=
.PHONY: cloud
cloud:
	qemu-img convert -O qcow2 "$$(fullvm-dest-image)" "$$(fullvm-dest-image).compact.qcow2"
	ls -lh "$$(fullvm-dest-image)*"
endef
fullvm-extra-rules += $(vhdx_convert_rule)

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms = base fullvm

$(call vm_eval_all_rules)

