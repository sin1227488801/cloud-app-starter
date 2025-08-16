variable "project"        { type = string }
variable "location"       { type = string }
variable "rg_name"        { type = string }
variable "subnet_id"      { type = string }
variable "admin_username" { type = string, default = "azureuser" }
variable "ssh_public_key" { type = string, default = "" }

resource "azurerm_public_ip" "pip" {
  name                = "${var.project}-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  idle_timeout_in_minutes = 4
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.project}-nic"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.project}-vm"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key != "" ? var.ssh_public_key : file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${var.project}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    project = var.project
    cost    = "b1s-mvp"
  }
}

output "public_ip" { value = azurerm_public_ip.pip.ip_address }
output "vm_name"   { value = azurerm_linux_virtual_machine.vm.name }
output "ssh_user"  { value = var.admin_username }
