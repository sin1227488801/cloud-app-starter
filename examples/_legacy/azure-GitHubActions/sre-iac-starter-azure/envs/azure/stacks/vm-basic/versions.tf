terraform {
  required_version = ">= 1.6.0"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

required_providers {
  local    = { source = "hashicorp/local", version = "~> 2.5" }
  template = { source = "hashicorp/template", version = "~> 2.2" }
}
