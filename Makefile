# Makefile for building the images

# user variables
VM_NAME = Win10_LTSC_2019_x64
TMP_DIR = /tmp/packer
VM_INSTALL_ISO = REQUIRED
VM_VIRTIO_ISO = REQUIRED
REUSE_IMAGE = 
PACKER = packer
TRANSFORMER = ./build/packer-transform.rb

VM_DIR = $(TMP_DIR)/$(VM_NAME)/
INPUT_FILE = Windows_x64.yaml
PACKER_ARGS = -on-error=abort
PACKER_TMP_DIR = $(TMP_DIR)
TMPDIR = $(TMP_DIR)
PACKER_CACHE_DIR = $(TMP_DIR)/packer_cache/

# export environment vars
export PACKER_TMP_DIR PACKER_CACHE_DIR TMPDIR VM_NAME VM_DIR VM_INSTALL_ISO VM_VIRTIO_ISO

# include local customizations file
include local.mk

# Packer image building
BASE_IMAGE = $(TMP_DIR)/$(VM_NAME)/$(VM_NAME)
REUSE_NEW_IMAGE = $(TMP_DIR)/$(VM_NAME)_new/$(VM_NAME)
ifeq ($(REUSE_IMAGE),1)
PACKER_ARGS := $(PACKER_ARGS) -var "use_disk_image=true" -var "iso_url=$(BASE_IMAGE)"
VM_DIR = $(TMP_DIR)/$(VM_NAME)_new/
endif

build: $(TMP_DIR)/
	$(if $(DELETE),rm -rf "$(VM_DIR)/",)
	cat $(INPUT_FILE) | $(TRANSFORMER) | $(PACKER) build $(PACKER_ARGS) -only=qemu -

validate:
	cat $(INPUT_FILE) | $(TRANSFORMER) | $(PACKER) validate -

# when REUSE_IMAGE=1: commits the image back into its backing image
commit:
	# packer uses symlink inside packer_cache which gets deleted, so update the
	# backing file reference to its real path
	qemu-img rebase -f qcow2 -u -b "$(BASE_IMAGE)" "$(REUSE_NEW_IMAGE)"
	qemu-img commit "$(REUSE_NEW_IMAGE)"

$(TMP_DIR)/:
	mkdir -p $(TMP_DIR)/

print-%  : ; @echo $* = $($*)

.PHONY: build validate

# targets for Vagrant image build / installation

VAGRANT_BOX_PATH = $(HOME)/.vagrant.d/boxes/me-VAGRANTSLASH-$(VM_NAME)/0/libvirt/box.img
LIBVIRT_IMG_NAME = me-VAGRANTSLASH-$(VM_NAME)_vagrant_box_image_0.img

metadata: $(VM_DIR)/metadata.json
$(VM_DIR)/metadata.json:
	BOX_SHA=$$(sha256sum "$(VM_DIR)/$(VM_NAME)-libvirt.box" | awk '{print $$1}'); \
			sed -e "s|{{LIBVIRT_BOX_FILE}}|$(VM_NAME)-libvirt.box|g" \
			-e "s|{{LIBVIRT_BOX_SHA}}|$$BOX_SHA|g" \
			metadata/win10_x64_metadata.json > $(VM_DIR)/metadata.json

install: $(VM_DIR)/metadata.json
	(cd "$(VM_DIR)"; vagrant box add "metadata.json" --name "me/$(VM_NAME)")

.PHONY: metadata install

