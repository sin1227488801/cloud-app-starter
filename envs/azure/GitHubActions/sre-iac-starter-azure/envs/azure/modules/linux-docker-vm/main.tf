terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ssh_allow_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.10.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-init.yaml")
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(data.template_file.cloud_init.rendered)

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "docker" {
  name                       = "install-docker"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  automatic_upgrade_enabled  = false

  settings = <<SETTINGS
  {
    "commandToExecute": "bash -lc 'curl -fsSL https://get.docker.com | sh && usermod -aG docker azureuser && systemctl enable --now docker'"
  }
SETTINGS
}

# Docker を VM 拡張(CustomScript)で導入（再実行しても安全）
resource "azurerm_virtual_machine_extension" "docker" {
  count                     = var.install_docker ? 1 : 0
  name                      = "install-docker"
  virtual_machine_id        = azurerm_linux_virtual_machine.vm.id
  publisher                 = "Microsoft.Azure.Extensions"
  type                      = "CustomScript"
  type_handler_version      = "2.1"
  automatic_upgrade_enabled = false

  # bash -lc でログインシェル相当。何度走っても壊れないようにガード付き
  settings = <<SETTINGS
{
  "commandToExecute": "bash -lc 'set -euo pipefail
    if ! command -v docker >/dev/null 2>&1; then
      curl -fsSL https://get.docker.com | sh
      systemctl enable --now docker
    fi
    # ユーザーを docker グループへ（存在しなければ作成）
    if ! getent group docker >/dev/null 2>&1; then
      groupadd docker
    fi
    usermod -aG docker azureuser
  '"
}
SETTINGS
}
