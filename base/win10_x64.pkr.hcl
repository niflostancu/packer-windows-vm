variables {
  vm_no_upgrade = 0
  virtio_win_iso = "<external>"
  source_image = "<external>"
  source_checksum = "none"
  winrm_timeout = "6h"
  http_directory = "http"

  install_from_idx = ""
  product_key = ""
  install_language = "en-US"
}

locals {
  win_base_qemu_args = [
    ["-drive", "file=${var.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=unmap,format=qcow2,detect-zeroes=${local.disk_discard}"],
    ["-drive", "file=${var.source_image},index=0,media=cdrom"],
    ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"],
  ]
  disk_discard   = (var.qemu_unmap ? "unmap" : "")
  envs = [
    "VM_DEBUG=${var.vm_debug}",
  ]
  provision_scripts = concat(
    ["./scripts/tweaks.ps1"],
    (var.vm_no_upgrade == 1 ? [] : ["./scripts/update.ps1"]),
    ["./scripts/updates-disable.ps1"]
  )
  shutdown_command = "shutdown /s /t 0 /f"
  execute_command = "powershell -ExecutionPolicy Bypass -Command \"{{.Path}}\""
}

source "qemu" "win" {
  // VM Info:
  vm_name       = var.vm_name
  headless      = false

  // Arch-specific qemu config
  qemu_binary  = local.qemu_arch_binary
  machine_type = local.qemu_arch_machine_type
  firmware     = local.qemu_arch_firmware
  accelerator  = local.qemu_arch_accelerator
  qemuargs     = concat(local.qemu_arch_qemuargs, local.win_base_qemu_args)
  // Virtual Hardware Specs
  memory         = var.memory
  cpus           = var.cpus
  disk_size      = var.disk_size
  disk_interface = "virtio"
  net_device     = "virtio-net"
  // disk usage optimizations (unmap zeroes as free space)
  disk_discard   = local.disk_discard
  disk_detect_zeroes = local.disk_discard
  // skip_compaction = true
  
  // ISO & Output details
  iso_url           = var.source_image
  iso_checksum      = var.source_checksum
  disk_image        = var.use_backing_file
  use_backing_file  = var.use_backing_file
  output_directory  = var.output_directory

  floppy_files = [
    "./scripts/winrm.ps1"
  ]
  floppy_content = {
    "Autounattend.xml" = templatefile("./unattend/win10x64.tmpl.xml", {
      installFromIndex = var.install_from_idx,
      productKey = var.product_key,
      installLanguage = var.install_language,
      winUser = var.ssh_username,
      winPassword = var.ssh_password,
      diskPartitionType = (local.qemu_arch_firmware == "" ? "mbr" : "efi"),
    })
  }
  http_directory = var.http_directory
  # Windows installer in EFI mode requires pressing any key to boot...
  boot_wait = (var.use_backing_file ? null : var.boot_wait)
  boot_command = ((var.use_backing_file || local.qemu_arch_firmware == "") ? null :
    ["<wait><esc><wait><esc><wait><esc><wait><esc>"])

  communicator = "winrm"
  winrm_username = var.ssh_username
  winrm_password = var.ssh_password
  winrm_timeout = var.winrm_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = "60m"
}

build {
  sources = ["sources.qemu.win"]

  provisioner "powershell" {
    scripts = local.provision_scripts

    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    valid_exit_codes = [0, 259, 1056]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
  }

  provisioner "breakpoint" {
    disable = (var.vm_pause == 0)
    note    = "this is a breakpoint"
  }
}


