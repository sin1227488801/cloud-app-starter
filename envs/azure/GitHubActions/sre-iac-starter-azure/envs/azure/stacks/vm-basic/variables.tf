variable "location" { type = string default = "japaneast" }
variable "resource_group_name" { type = string default = "sre-iac-rg" }
variable "vm_name" { type = string default = "sre-docker-vm" }
variable "ssh_public_key_path" { type = string default = "~/.ssh/id_rsa.pub" }
variable "ssh_allow_cidrs" { type = list(string) default = ["0.0.0.0/0"] }
