## Makefile for Development VM (Python3, VSCode, git)

# first, load local config (you need to clone it first from the sample!
include config.local.mk
# the config should have defined the WIN_PKR_SCRIPTS_DIR by now:
# also load parent windows packer config, then the base VM framework
include $(WIN_PKR_SCRIPTS_DIR)/config.local.mk
FRAMEWORK_DIR ?= $(WIN_PKR_SCRIPTS_DIR)/framework
include $(FRAMEWORK_DIR)/framework.mk
# load extra modules
include $(FRAMEWORK_DIR)/lib/arch.mk
include $(FRAMEWORK_DIR)/lib/gen_vm_combo.mk
include $(FRAMEWORK_DIR)/lib/zerofree.mk

# override windows VM user
VM_USER = developer
VM_PASSWORD = developer
ZEROFREE_PART_NUM = 1
SSH_PORT=20122
SSH_USER=developer

# set default goals
DEFAULT_GOAL = dev_vm
INIT_GOAL = dev_vm

# Assignment VM
dev_vm-ver = $(APP_VM_VERSION)
dev_vm-name = My_Gov_Apps_$(mygov-ver)
dev_vm-src-image = $(WIN_PKT_BASE_IMAGE)
dev_vm-packer-src = $(WIN_PKR_SCRIPTS_DIR)/generic

dev_vm-copy-scripts = $(abspath $(WIN_PKR_SCRIPTS_DIR)/vmscripts)/
dev_vm-copy-scripts += $(abspath ./vmscripts)/

# copy extra files
dev_vm-packer-args += -var 'vm_scripts_list=$(-vm-copy-scripts-list)'
dev_vm-packer-args += $(call _packer_var,vm_no_provision,$(NO_PROVISION))
dev_vm-packer-args += $(call _packer_var,vm_install_tasks,install-dev.d/)
dev_vm-packer-args += $(call _packer_var,vm_stage2_idx,30)
dev_vm-packer-args += $(call _packer_var,vm_stage3_idx,30)
dev_vm-extra-rules += $(vm_zerofree_rule)

# Export the main VM to both VirtualBox & VMware using the ComboVM rules
# [re]build with `make exported_clean exported`
export-name = $(dev_vm-name)_export
# must change the target's type to `vm-combo` for combo export rules
export-type = vm-combo
export-vmname = My Dev VM $(APP_VM_VERSION)
export-src-from = dev_vm

# list with all VMs to generate rules for (note: use dependency ordering!)
build-vms = dev_vm export

# do some configuration checks before the rules...
$(call check-var,WIN_PKR_SCRIPTS_DIR)
$(call check-var,WIN_PKT_BASE_IMAGE)
# generate VM build rules
$(call vm_eval_all_rules)

