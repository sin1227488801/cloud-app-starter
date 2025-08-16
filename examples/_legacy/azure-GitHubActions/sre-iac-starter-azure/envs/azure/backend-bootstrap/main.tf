terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.backend_rg_name
  location = var.location
  tags     = { Project = "sre-iac-starter" }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "azurerm_storage_account" "sa" {
  name                            = "${var.backend_sa_prefix}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = { Project = "sre-iac-starter" }
}

resource "azurerm_storage_container" "tf" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# 出力は main.tf 側に一本化（outputs.tf は削除済）
output "backend_resource_group" {
  value = azurerm_resource_group.rg.name
}
output "backend_storage_account" {
  value = azurerm_storage_account.sa.name
}
output "backend_container" {
  value = azurerm_storage_container.tf.name
}
