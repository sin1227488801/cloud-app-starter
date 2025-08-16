variable "project" {}
variable "env" {}

resource "azurerm_virtual_network" "main" {
  name                = "${var.project}-${var.env}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "Japan East"
  resource_group_name = azurerm_resource_group.main.name
}
