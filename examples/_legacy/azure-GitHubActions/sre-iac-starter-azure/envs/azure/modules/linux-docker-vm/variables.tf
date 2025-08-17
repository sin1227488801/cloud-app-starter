variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_allow_cidrs" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "install_docker" {
  type    = bool
  default = true
}
