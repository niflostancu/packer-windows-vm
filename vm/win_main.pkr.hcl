packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variables {
  vm_name = "win10"
  vm_pause = 0
  vm_debug = 0
  vm_no_upgrade = 0
  virtio_win_iso = "<external>"
  qemu_unmap = true
  qemu_ssh_forward = 20022
  disk_size = "20972"
  memory = "4096"
  cpus = "4"
  source_image = "<external>"
  source_checksum = "none"
  use_backing_file = true
  output_directory = "/tmp/packer-out"
  winrm_username = "vagrant"
  winrm_password = "vagrant"
  winrm_timeout = "6h"
  http_directory = "http"
}

locals {
  disk_discard   = (var.qemu_unmap ? "unmap" : "")
  envs = [
    "VM_DEBUG=${var.vm_debug}",
  ]
  provision_scripts = concat(
    ["./scripts/tweaks.ps1"],
    (var.vm_no_upgrade == 1 ? [] : ["./scripts/update.ps1"])
  )
  shutdown_command = "shutdown /s /t 0 /f"
  execute_command = "powershell -ExecutionPolicy Bypass -Command \"{{.Path}}\""
}

source "qemu" "win" {
  // VM Info:
  vm_name       = var.vm_name
  headless      = false

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
  // override qemu args for to mount all drives
  qemuargs = [
    ["-vga", "none"],
    ["-device", "qxl-vga,vgamem_mb=32"],
    ["-usb"], ["-device", "usb-tablet"],
    ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"],
    ["-drive", "file=${var.output_directory}/{{ .Name }},if=virtio,cache=writeback,discard=unmap,format=qcow2,detect-zeroes=${local.disk_discard}"],
  ]

  http_directory = var.http_directory

  communicator = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_timeout = var.winrm_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = "60m"
}

build {
  sources = ["sources.qemu.win"]

  provisioner "file" {
    source = "./scripts/machine/"
    destination = "C:/Windows/vmfiles"
  }

  provisioner "powershell" {
    scripts = [
      "./scripts/10-tweaks.ps1",
      "./scripts/15-virt-drivers.ps1",
    ]
    elevated_user = var.winrm_username
    elevated_password = var.winrm_password
    execute_command = local.execute_command
    valid_exit_codes = [0, 259]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
  }

  # continue with the scripts
  provisioner "powershell" {
    scripts = [
      "./scripts/30-chocolatey.ps1",
      "./scripts/35-msys.ps1",
      "./scripts/90-cleanup.ps1",
      # "./scripts/sysprep.ps1"
    ]
    elevated_user = var.winrm_username
    elevated_password = var.winrm_password
    execute_command = local.execute_command
  }

  provisioner "breakpoint" {
    disable = (var.vm_pause == 0)
    note    = "this is a breakpoint"
  }
}

