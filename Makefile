# Makefile for building the images

VM_NAME=Win10LTSB_x64
TMP_DIR=/tmp/packer
OUT_DIR=$(TMP_DIR)/$(VM_NAME)
LIBVIRT_IMAGES_DIR=/var/lib/libvirt/images
ARGS=-on-error=abort
REUSE_IMAGE=

ifneq ($(REUSE_IMAGE),)
ARGS:=$(ARGS) -var "use_disk_image=true" -var "iso_url=$(OUT_DIR)/$(VM_NAME)" \
	-on-error=abort -force
OUT_DIR:=$(TMP_DIR)/$(VM_NAME)_disk
endif

all: win10_x64

win10_x64:
	PACKER_TMP_DIR="$(TMP_DIR)" TMPDIR="$(TMP_DIR)" VM_OUTPUT_DIR="$(OUT_DIR)" \
		packer-io build -var-file=variables.local.json -var "vm_name=$(VM_NAME)" \
		$(ARGS) -only=qemu windows.json

win10_x64_metadata: $(OUT_DIR)/metadata.json
$(OUT_DIR)/metadata.json:
	BOX_SHA=$$(sha256sum "$(OUT_DIR)/$(VM_NAME)-libvirt.box" | awk '{print $$1}'); \
			sed -e "s|{{LIBVIRT_BOX_FILE}}|$(VM_NAME)-libvirt.box|g" \
			-e "s|{{LIBVIRT_BOX_SHA}}|$$BOX_SHA|g" \
			metadata/win10_x64_metadata.json > $(OUT_DIR)/metadata.json

print-%  : ; @echo $* = $($*)

VAGRANT_BOX_PATH=$(HOME)/.vagrant.d/boxes/me-VAGRANTSLASH-$(VM_NAME)/0/libvirt/box.img
LIBVIRT_IMG_NAME=me-VAGRANTSLASH-$(VM_NAME)_vagrant_box_image_0.img

install_win10_x64: $(OUT_DIR)/metadata.json
	(cd "$(OUT_DIR)"; vagrant box add "metadata.json" --name "me/$(VM_NAME)")

.PHONY: all win10_x64 install_win10_x64

