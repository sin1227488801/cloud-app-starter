variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "azure_location" {
  type = string
}

# backend helper vars:
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
