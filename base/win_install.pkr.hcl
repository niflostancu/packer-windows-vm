# Base Windows install packer script

variables {
  vm_name = "win_base"
  vm_no_upgrade = 0
  vm_no_provision = 0
  vm_do_sysprep = 0
  vm_scripts_dir = "../vmscripts/"
  vm_install_script = "vmscript-exec.ps1"
  vm_install_tasks = "install-base.d/"

  source_image = "<external>"
  source_checksum = "none"
  extra_iso = ""
  winrm_timeout = "6h"
  http_directory = "http"
  use_backing_file = false

  win_variant = "win10_x64"
  install_from_idx = ""
  product_key = ""
  install_language = "en-US"
}
variable "vm_scripts_list" {
  type    = list(string)
  default = []
}
variable "vm_extra_envs" {
  type    = list(string)
  default = []
}

locals {
  # qemu args for Base Windows install (mounting two ISOs)
  win_base_qemuargs = concat([
      ["-drive", "file=${var.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=${local.qemu_discard},format=qcow2,detect-zeroes=${local.qemu_discard}"],
      ["-drive", "file=${var.source_image},index=0,media=cdrom"]
    ], (var.extra_iso == "" ? [] : [
      ["-drive", "file=${var.extra_iso},media=cdrom,index=3"]
    ])
  )
  envs = concat([
    "VMSCRIPTS=C:\\Windows\\vmscripts",
    "VM_DEBUG=${var.vm_debug}",
    "VM_NO_UPGRADE=${var.vm_no_upgrade}",
    "VM_NO_PROVISION=${var.vm_no_provision}",
    "VM_DO_SYSPREP=${var.vm_do_sysprep}",
  ], var.vm_extra_envs)
  _vm_runner = "C:\\Windows\\vmscripts\\bin\\${var.vm_install_script}"
  shutdown_command = "shutdown /s /t 0 /f"
  execute_command = "powershell -ExecutionPolicy Bypass -Command \"{{.Path}}\""
}

source "qemu" "windows" {
  // VM Info:
  vm_name       = var.vm_name
  headless      = false

  // Arch-specific qemu config
  qemu_binary  = local.qemu_arch_binary
  machine_type = local.qemu_arch_machine_type
  firmware     = local.qemu_arch_firmware
  accelerator  = local.qemu_arch_accelerator
  qemuargs     = concat(local.qemu_arch_qemuargs, local.spice_qxl_devs_qemuargs,
                        local.win_base_qemuargs)

  // Virtual Hardware Specs
  memory         = var.memory
  cpus           = var.cpus
  disk_size      = var.disk_size
  disk_interface = "virtio"
  net_device     = "virtio-net"
  // disk usage optimizations (unmap zeroes as free space)
  disk_discard   = local.qemu_discard
  disk_detect_zeroes = local.qemu_discard
  // skip_compaction = true
  
  // ISO & Output details
  iso_url           = var.source_image
  iso_checksum      = var.source_checksum
  disk_image        = var.use_backing_file
  use_backing_file  = var.use_backing_file
  output_directory  = var.output_directory

  floppy_files = [
    "./install_scripts/init-winrm.ps1"
  ]
  floppy_content = {
    "Autounattend.xml" = templatefile("./unattend/${var.win_variant}.tmpl.xml", {
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
  sources = ["sources.qemu.windows"]

  provisioner "file" {
    sources = concat(
      (var.vm_scripts_dir != "" ? [var.vm_scripts_dir] : []),
      var.vm_scripts_list
    )
    destination = "C:/Windows/vmscripts/"
  }

  # VM install pipeline: prepare, stage1 (01 -> 20), reboot, 
  # .. do windows updates (20 -> 30), reboot, stage 2 (30 -> 99)

  provisioner "powershell" {
    inline = (var.vm_no_provision >= 1 ? ["Write-Output '<skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -UntilIdx 20",
      ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
    valid_exit_codes = [0, 259, 1056]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
    restart_command = (var.vm_no_provision >= 1 ? 
      "powershell -command \"& {Write-Output 'mock restart.'}\"" : 
      "shutdown /r /f /t 0 /c \"packer restart\"")
    # check_registry = true
  }

  provisioner "powershell" {
    inline = (var.vm_no_upgrade >= 1 ? ["Write-Output '<skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -FromIdx 20 -UntilIdx 30",
      ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
    restart_command = (var.vm_no_upgrade >= 1 ? 
      "powershell -command \"& {Write-Output 'mock restart.'}\"" : 
      "shutdown /r /f /t 0 /c \"packer restart\"")
    # check_registry = true
  }

  provisioner "powershell" {
    inline = (var.vm_no_provision >= 2 ? ["Write-Output '<skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -FromIdx 30",
      ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
  }

  provisioner "breakpoint" {
    disable = (var.vm_pause == 0)
    note    = "this is a breakpoint"
  }
}


