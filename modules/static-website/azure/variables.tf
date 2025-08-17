variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "project" {
  description = "Project name for resource naming (will be shortened for storage account)"
  type        = string
  default     = "sreiac"
}

variable "env" {
  description = "Environment name for resource naming"
  type        = string
  default     = "dev"
}
