terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Random suffix for unique storage account name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Local value for storage account name (max 24 chars)
locals {
  # Ensure storage account name is within Azure limits
  project_short = substr(replace(lower(var.project), "-", ""), 0, 6)
  env_short     = substr(var.env, 0, 3)
  sa_name       = "${local.project_short}${local.env_short}${random_string.suffix.result}"
}

# Storage Account for static website
resource "azurerm_storage_account" "static_site" {
  name                     = local.sa_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Enable static website
  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  # Disable public blob access by default
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  tags = {
    project     = var.project
    environment = var.env
    purpose     = "static-website"
  }
}

# Configure blob public access (only for $web container)
resource "azurerm_storage_account_network_rules" "static_site" {
  storage_account_id = azurerm_storage_account.static_site.id

  default_action = "Allow"
}
