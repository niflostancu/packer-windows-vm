variables {
  vm_name = "win10"
  vm_no_upgrade = 0
  vm_no_provision = 0
  vm_scripts_dir = "../vmscripts/"
  vm_install_script = "vmscript-exec.ps1"
  vm_install_tasks = "install-generic.d/"
  vm_stage2_idx = 30
  vm_stage3_idx = 30
  http_directory = ""

  source_image = "<external>"
  source_checksum = "none"
  extra_iso = ""
  winrm_timeout = "6h"
  use_backing_file = true
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
  win_generic_qemuargs = concat([
      ["-drive", "file=${var.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=${local.qemu_discard},format=qcow2,detect-zeroes=${local.qemu_discard}"],
      [ "-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:5985,hostfwd=tcp::20122-:22,id=winnet"],
      [ "-device", "virtio-net,netdev=winnet,id=net0"]
    ], (var.extra_iso == "" ? [] : [
      ["-drive", "file=${var.extra_iso},media=cdrom,index=3"]
    ])
  )
  envs = concat([
    "VMSCRIPTS=C:\\Windows\\vmscripts",
    "VM_DEBUG=${var.vm_debug}",
    "VM_NO_UPGRADE=${var.vm_no_upgrade}",
    "VM_NO_PROVISION=${var.vm_no_provision}",
  ], var.vm_extra_envs)

  _no_run_mid_stage = (var.vm_stage2_idx == var.vm_stage3_idx)
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
                        local.win_generic_qemuargs)
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

  communicator   = "winrm"
  winrm_username = var.ssh_username
  winrm_password = var.ssh_password
  winrm_timeout  = var.winrm_timeout
  http_directory = var.http_directory

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
    destination = "C:/Windows/vmscripts"
  }

  # default VM build pipeline: copy scripts, (stage + reboot)^3, breakpoint

  provisioner "powershell" {
    inline = (var.vm_no_provision >= 1 ? ["Write-Output '<stage1 skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -UntilIdx ${var.vm_stage2_idx}",
      ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
    restart_command = (var.vm_no_provision >= 1 ? 
      "powershell -command \"& {Write-Output 'mock restart.'}\"" : 
      "shutdown /r /f /t 0 /c \"packer restart\"")
    # check_registry = true
  }

  provisioner "powershell" {
    inline = (var.vm_no_provision >= 1 || local._no_run_mid_stage ? ["Write-Output '<stage2 skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -FromIdx ${var.vm_stage2_idx} -UntilIdx ${var.vm_stage3_idx}",
      ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
  }
  provisioner "windows-restart" {
    restart_timeout = "60m"
    restart_command = (var.vm_no_provision >= 1 || local._no_run_mid_stage ? 
      "powershell -command \"& {Write-Output 'mock restart.'}\"" : 
      "shutdown /r /f /t 0 /c \"packer restart\"")
    # check_registry = true
  }

  provisioner "powershell" {
    inline = (var.vm_no_provision >= 1 ? ["Write-Output '<stage3 skipped>'"] : [
        "& '${local._vm_runner}' -Path '${var.vm_install_tasks}' -FromIdx ${var.vm_stage3_idx}",
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


