output "vm_public_ip" {
  value = module.vm.public_ip
  description = "Public IP address of the Docker-enabled Ubuntu VM"
}
