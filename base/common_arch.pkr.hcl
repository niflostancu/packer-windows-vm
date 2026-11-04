// Common Packer qemu/arch-specific definitions

variables {
  // user-configurable qemu overrides
  arch = "x86_64"
  qemu_binary = ""
  qemu_machine_type = ""
  qemu_accelerator = ""
  qemu_firmware = ""
  qemu_vgamem = "256"
  qemu_unmap = true
  qemu_zero = "on"
  qemu_extra_drive = ""
  qemu_spice_port = 5930
}
variable "qemu_args" {
  type    = list(list(string))
  default = []
}
// run qemu without a GUI (headless); VNC is still started by Packer
variable "headless" {
  type    = bool
  default = false
}
// expose the QEMU HMP monitor on this UNIX socket path (empty = disabled)
variable "qemu_monitor" {
  type    = string
  default = ""
}
// log the guest serial console to this file path (empty = disabled)
variable "qemu_serial" {
  type    = string
  default = ""
}

locals {
  // arch-specialized aliases
  _qemu_discard = (var.qemu_unmap ? ",discard=unmap,detect-zeroes=${var.qemu_zero}" : "")
  qemu_def_drv_args = "if=virtio,format=qcow2,cache=writeback${local._qemu_discard}"
  qemu_def_drive = ["-drive", "file=${var.output_directory}/{{ .Name }},${local.qemu_def_drv_args}"]
  qemu_def_iso = ["-drive", "file=${var.source_image},media=cdrom"]
  // optional console debugging devices (see lib/qemu_debug.mk)
  qemu_console_args = concat(
    (var.qemu_monitor == "" ? [] : [["-monitor", "unix:${var.qemu_monitor},server,nowait"]]),
    (var.qemu_serial == "" ? [] : [["-serial", "file:${var.qemu_serial}"]]),
  )
  qemu_arch_binary = lookup(lookup(local.qemu_arch_defs, var.arch, {}), "qemu_binary", "")
  qemu_arch_machine_type = lookup(lookup(local.qemu_arch_defs, var.arch, {}), "machine_type", "")
  qemu_arch_firmware = lookup(lookup(local.qemu_arch_defs, var.arch, {}), "firmware", "")
  qemu_arch_accelerator  = lookup(lookup(local.qemu_arch_defs, var.arch, {}), "accelerator", "")
  # qemu args for QXL + SPICE integration 
  spice_qxl_devs_qemuargs = [
    ["-vga", "none"],
    ["-device", "qxl-vga,vgamem_mb=${var.qemu_vgamem},ram_size_mb=${var.qemu_vgamem},vram_size_mb=${var.qemu_vgamem}"],
    ["-usb"], ["-device", "usb-tablet"],
    ["-spice", "port=${var.qemu_spice_port},disable-ticketing=on"],
    ["-device", "virtio-serial"],
    ["-chardev", "spicevmc,id=vdagent,name=vdagent"],
    ["-device", "virtserialport,chardev=vdagent,name=com.redhat.spice.0"],
    ["-display", "spice-app"]
  ]
  # expose both WinRM (communicator) and SSH (optional, if installed)
  qemu_network_args = [
    [ "-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:5985,hostfwd=tcp::${var.win_ssh_port}-:22,id=winnet"],
    [ "-device", "virtio-net,netdev=winnet,id=net0"]
  ]
  # build the full qemu args string
  qemu_arch_qemuargs = concat(
    [local.qemu_def_drive], // default disk
    // ISO drive, if base install + extra drive (e.g., additional ISO)
    (var.use_backing_file ? [] : [local.qemu_def_iso]),
    (var.qemu_extra_drive == "" ? [] : [["-drive", var.qemu_extra_drive]]),
    // extra qemu / arch-specific customizations
    lookup(lookup(local.qemu_arch_defs, var.arch, {}), "extra_args", []),
    local.spice_qxl_devs_qemuargs, local.qemu_network_args,
    local.qemu_console_args, var.qemu_args
  )

  // definitions
  qemu_arch_defs = {
    "x86_64" = {
      qemu_binary  = (var.qemu_binary != "" ? var.qemu_binary : "qemu-system-x86_64")
      firmware     = var.qemu_firmware
      use_pflash   = false
      machine_type = (var.qemu_machine_type != "" ? var.qemu_machine_type : "pc")
      accelerator  = (var.qemu_accelerator != "" ? var.qemu_accelerator : "kvm")
      extra_args   = []
    }
  }
}
