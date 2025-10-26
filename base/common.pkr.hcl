packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variables {
  vm_name = "win_base"
  vm_locale = "en_US"
  vm_timezone = "Europe/Bucharest"
  vm_pause = 0
  vm_debug = 0
  vm_scripts_dir = "scripts/"
  qemu_unmap = true
  qemu_ssh_forward = 20022
  disk_size = 30720
  memory = "4096"
  cpus = "4"
  use_backing_file = false
  output_directory = "/tmp/packer-out"
  boot_wait = "2s"
  ssh_username = "TODO"
  ssh_password = "TODO"
}
