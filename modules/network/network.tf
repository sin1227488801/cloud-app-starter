variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "Japan East"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.project}-${var.env}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}
