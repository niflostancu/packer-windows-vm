# Makefile for building the images

# user variables
TMP_DIR = /tmp/packer
OS_INSTALL_ISO = REQUIRED
VIRTIO_INSTALL_ISO = REQUIRED

PACKER = packer
PACKER_ARGS = -on-error=abort -var "debug=$(DEBUG)"
DEBUG =  # set to 1 to keep the files at the end of the operation
PAUSE = $(DEBUG)
TRANSFORMER = ./build/packer-transform.py

# Fresh Ubuntu 18.04 base install
BASE_VM_NAME = Win10_LTSC_base
BASE_PACKER_CONFIG = base/win10_x64_base.yaml
BASE_VM_IMAGE = $(TMP_DIR)/$(BASE_VM_NAME)/$(BASE_VM_NAME).qcow2

# main RL scripts image (from BASE)
WIN_VM_NAME = Win10_LTSC_VM
WIN_VM_PACKER_CONFIG = vm/win10_vm.yaml
WIN_VM_IMAGE = $(TMP_DIR)/$(WIN_VM_NAME)/$(WIN_VM_NAME).qcow2

WIN_VAGRANT_PACKER_CONFIG = vm/win10_vagrant_full.yaml

PACKER_ARGS += -var 'virtio_win_iso=$(VIRTIO_INSTALL_ISO)'

# include local customizations file
include build/utils.mk
include local.mk

# VM build targets
all: vm
.PHONY: all

# Base image
BASE_DEPS = base/win10_x64_base.yaml $(wildcard base/scripts/*)
base: $(BASE_VM_IMAGE)
$(BASE_VM_IMAGE): $(BASE_DEPS) | $(TMP_DIR)/
	$(call packer_gen_build, $(BASE_PACKER_CONFIG), \
		$(BASE_VM_NAME), $(OS_INSTALL_ISO))

# base VM editing using a backing disk (for quickly applying updates)
base_edit: PACKER_ARGS += -var 'use_backing_file=1'
base_edit: $(BASE_DEPS) | $(BASE_VM_IMAGE)
	$(call packer_gen_build, $(BASE_PACKER_CONFIG), \
		$(BASE_VM_NAME)_tmp, $(BASE_VM_IMAGE))
# commits the edited image back to the original
BASE_VM_TMP_IMAGE = $(TMP_DIR)/$(BASE_VM_NAME)_tmp/$(BASE_VM_NAME)_tmp.qcow2
base_commit:
	qemu-img commit "$(BASE_VM_TMP_IMAGE)"
	rm -rf "$(TMP_DIR)/$(BASE_VM_NAME)_tmp/"

.PHONY: base base_edit base_commit

# The final Windows VM with programs / scripts installed
VM_DEPS = vm/win10_vm.yaml $(wildcard vm/scripts/*)
vm: $(WIN_VM_IMAGE)
$(WIN_VM_IMAGE): PACKER_ARGS += -var 'use_backing_file=1'
$(WIN_VM_IMAGE): $(VM_DEPS)
	$(call packer_gen_build, $(WIN_VM_PACKER_CONFIG), \
		$(WIN_VM_NAME), $(BASE_VM_IMAGE))

# Edit an existing VM image
vm_edit: PACKER_ARGS += -var 'use_backing_file=1'
vm_edit: $(VM_DEPS)
	$(call packer_gen_build, $(WIN_VM_PACKER_CONFIG), \
		$(WIN_VM_NAME)_tmp, $(WIN_VM_IMAGE))
# commits the edited image back to the original
WIN_VM_TMP_IMAGE = $(TMP_DIR)/$(WIN_VM_NAME)_tmp/$(WIN_VM_NAME)_tmp.qcow2
vm_commit:
	qemu-img commit "$(WIN_VM_TMP_IMAGE)"
	rm -rf "$(TMP_DIR)/$(WIN_VM_NAME)_tmp/"

.PHONY: vm vm_edit vm_commit

$(TMP_DIR)/:
	mkdir -p $(TMP_DIR)/

print-%  : ; @echo $* = $($*)

# targets for Vagrant image build / installation

# creates a large vagrant .box with the full image
vagrant_full: $(WIN_VM_PACKER_CONFIG)
	$(call packer_gen_build, $(WIN_VAGRANT_PACKER_CONFIG), \
		$(WIN_VM_NAME)_vagrant, $(WIN_VM_IMAGE))

# Creates a light box (containing a small image with the VM disk as backed file)
# You need to manually copy the backing image to the libvirt storage
VAGRANT_BOX_DEST=$(TMP_DIR)/$(WIN_VM_NAME)_vagrant
VAGRANT_BACKING_FILE = $(VAGRANT_BOX_DEST)/$(WIN_VM_NAME).qcow2
vagrant_lite: $(VAGRANT_BOX_DEST)/metadata.json $(VAGRANT_BOX_DEST)/box.img
	cp "Vagrantfile.template" "$(VAGRANT_BOX_DEST)/Vagrantfile"
	tar cvzf "$(VAGRANT_BOX_DEST)/$(WIN_VM_NAME).box" -C "$(VAGRANT_BOX_DEST)" ./metadata.json ./Vagrantfile ./box.img

define VAGRANT_METADATA
{
    "provider": "libvirt", 
	"format": "qcow2", 
	"virtual_size": 20
}
endef
export VAGRANT_METADATA

$(VAGRANT_BOX_DEST)/metadata.json:
	@mkdir -p "$(VAGRANT_BOX_DEST)" && \
	echo "$$VAGRANT_METADATA" > "$(VAGRANT_BOX_DEST)/metadata.json"

$(VAGRANT_BACKING_FILE): $(VAGRANT_BOX_DEST)/metadata.json
	qemu-img convert -f qcow2 -O qcow2 "$(WIN_VM_IMAGE)" "$@"

$(VAGRANT_BOX_DEST)/box.img: $(VAGRANT_BACKING_FILE)
	qemu-img create -f qcow2 -b "$(WIN_VM_NAME).qcow2" "$@"

# uploads the backing image to the given libvirt storage pool
virt_install: | $(VAGRANT_BACKING_FILE)
	VOL_NAME="$$(basename "$(VAGRANT_BACKING_FILE)")" && \
	virsh -c "$(LIBVIRT_CONNECTION)" vol-create-as "$(LIBVIRT_POOL)" \
		"$$VOL_NAME" 20G --format qcow2 --allocation 0; \
	virsh -c "$(LIBVIRT_CONNECTION)" vol-upload --pool "$(LIBVIRT_POOL)" \
		"$$VOL_NAME" "$(VAGRANT_BACKING_FILE)"

.PHONY: vagrant_lite vagrant_full vagrant_lite_install

