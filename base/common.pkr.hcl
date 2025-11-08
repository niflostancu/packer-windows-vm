packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variables {
  vm_locale = "en_US"
  vm_timezone = "Europe/Bucharest"
  vm_pause = 0
  vm_debug = 0
  disk_size = 30720
  memory = "4096"
  cpus = "4"
  output_directory = "/tmp/packer-out"
  boot_wait = "2s"
  ssh_username = "TODO"
  ssh_password = "TODO"
}
