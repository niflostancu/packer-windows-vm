# Makefile utils

# macro for packer build script generation
# args:
_VM_TEMPLATE = $(strip $(1))
_VM_NAME = $(strip $(2))
_VM_SOURCE = $(strip $(3))
_VM_DIR = $(TMP_DIR)/$(_VM_NAME)
_TRANSFORM_ARGS=$(if $(PAUSE),--add-breakpoint,)
define packer_gen_build
	$(if $(DELETE),rm -rf "$(_VM_DIR)/",)
	cat "$(_VM_TEMPLATE)" | $(TRANSFORMER) $(_TRANSFORM_ARGS) | \
		env "PACKER_TMP_DIR=$(TMP_DIR)" "PACKER_CACHE_DIR=$(TMP_DIR)/packer_cache/" \
		"TMPDIR=$(TMP_DIR)" "VM_NAME=$(_VM_NAME)" "OUTPUT_DIR=$(_VM_DIR)" \
		"PACKER_LOG=$(DEBUG)" "SOURCE_IMAGE=$(_VM_SOURCE)" \
		$(PACKER) build $(PACKER_ARGS) -only=qemu -
endef


