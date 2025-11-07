variables {
  vm_name = "win10"
  vm_no_upgrade = 0
  vm_no_provision = 0
  virtio_win_iso = "<external>"
  source_image = "<external>"
  source_checksum = "none"
  winrm_timeout = "6h"
  use_backing_file = true
}

locals {
  disk_discard   = (var.qemu_unmap ? "unmap" : "")
  envs = [
    "VM_DEBUG=${var.vm_debug}",
  ]
  shutdown_command = "shutdown /s /t 0 /f"
  execute_command = "powershell -ExecutionPolicy Bypass -Command \"{{.Path}}\""
  win_full_qemuargs = [
    ["-vga", "none"],
    ["-device", "qxl-vga,vgamem_mb=256,ram_size_mb=256,vram_size_mb=256"],
    ["-usb"], ["-device", "usb-tablet"],
    ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"],
    ["-drive", "file=${var.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=unmap,format=qcow2,detect-zeroes=${local.disk_discard}"],
    ["-spice", "port=5930,disable-ticketing=on"],
    ["-device", "virtio-serial"],
    ["-chardev", "spicevmc,id=vdagent,name=vdagent"],
    ["-device", "virtserialport,chardev=vdagent,name=com.redhat.spice.0"],
    ["-display", "spice-app"]
  ]
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
  qemuargs     = concat(local.win_full_qemuargs, local.qemu_arch_qemuargs)
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

  communicator   = "winrm"
  winrm_username = var.ssh_username
  winrm_password = var.ssh_password
  winrm_timeout  = var.winrm_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = "60m"
}

build {
  sources = ["sources.qemu.win"]

  provisioner "file" {
    source = "./scripts/files/"
    destination = "C:/Windows/vmfiles/"
  }

  provisioner "powershell" {
    scripts = (var.vm_no_provision >= 1 ? ["./scripts/_dummy.ps1"] : [
      "./scripts/10-tweaks.ps1",
      "./scripts/15-virt-drivers.ps1",
    ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
    valid_exit_codes = [0, 259]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
    restart_command = (var.vm_no_provision >= 1 ? 
      "powershell -command \"& {Write-Output 'mock restart.'}\"" : 
      "shutdown /r /f /t 0 /c \"packer restart\"")
    # check_registry = true
  }

  provisioner "powershell" {
    scripts = (var.vm_no_provision > 1 ? ["./scripts/_dummy.ps1"] : [
      "./scripts/20-pkg-managers.ps1",
      "./scripts/32-default-apps.ps1",
      "./scripts/35-msys.ps1",
      "./scripts/66-debloat.ps1",
      "./scripts/90-cleanup.ps1",
      // "./scripts/90-sysprep.ps1"
    ])
    elevated_user = var.ssh_username
    elevated_password = var.ssh_password
    execute_command = local.execute_command
    valid_exit_codes = [0, 259]
  }

  provisioner "breakpoint" {
    disable = (var.vm_pause == 0)
    note    = "this is a breakpoint"
  }
}


