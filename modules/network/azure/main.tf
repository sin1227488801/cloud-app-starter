variable "project" {
  type = string
}

variable "location" {
  type = string
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg"
  location = var.location
  tags     = { project = var.project }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

output "subnet_id" { value = azurerm_subnet.app.id }
