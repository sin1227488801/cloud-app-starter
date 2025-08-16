variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "bucket" {
  type    = string
  default = "sre-iac-starter-tfstate"
}

variable "dynamodb_table" {
  type    = string
  default = "sre-iac-starter-tf-lock"
}
