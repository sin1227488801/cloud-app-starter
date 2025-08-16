terraform {
  required_version = "~> 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.117" }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "azure_location" {
  type = string
}

# backend vars (pass via TF_VAR_*)
variable "azure_state_rg" {
  type = string
}

variable "azure_state_account" {
  type = string
}

variable "azure_state_container" {
  type = string
}

variable "azure_state_key" {
  type = string
}
