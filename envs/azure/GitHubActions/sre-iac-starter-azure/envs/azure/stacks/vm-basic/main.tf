# Read SSH public key from local file
data "local_file" "ssh_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = { Project = "sre-iac-starter" }
}

module "vm" {
  source              = "../../modules/linux-docker-vm"
  name                = var.vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = "Standard_B1s"
  ssh_public_key      = data.local_file.ssh_key.content
  ssh_allow_cidrs     = var.ssh_allow_cidrs
  tags                = { Project = "sre-iac-starter", Env = "dev" }
}

output "vm_public_ip" {
  value = module.vm.public_ip
}
