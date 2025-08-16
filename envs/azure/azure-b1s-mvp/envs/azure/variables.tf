variable "project"        { type = string }
variable "env"            { type = string }
variable "azure_location" { type = string }
variable "azure_state_rg"        { type = string }
variable "azure_state_account"   { type = string }
variable "azure_state_container" { type = string }
variable "azure_state_key"       { type = string }
variable "admin_username" { type = string, default = "azureuser" }
variable "ssh_public_key" { type = string, default = "" }
