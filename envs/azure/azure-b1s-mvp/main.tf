terraform {
  required_version = "~> 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.117" }
  }
}

provider "azurerm" {
  features {}
}

module "network" {
  source   = "../../modules/network/azure"
  project  = var.project
  location = var.location
}

module "compute" {
  source    = "../../modules/compute/azure"
  project   = var.project
  location  = var.location
  subnet_id = module.network.subnet_id
}
