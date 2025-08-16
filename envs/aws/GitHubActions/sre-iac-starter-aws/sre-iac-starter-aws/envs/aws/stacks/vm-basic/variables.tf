variable "region"    { type = string default = "ap-northeast-1" }
variable "vpc_id"    { type = string default = "" }
variable "subnet_id" { type = string default = "" }
variable "ssh_cidrs" { type = list(string) default = ["0.0.0.0/0"] }
