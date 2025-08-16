variable "location" {
  type    = string
  default = "japaneast"
}

variable "backend_rg_name" {
  type    = string
  default = "sre-iac-rg-backend"
}

variable "backend_sa_prefix" {
  type    = string
  default = "sreiactfstate"
}

variable "backend_container_name" {
  type    = string
  default = "tfstate"
}
