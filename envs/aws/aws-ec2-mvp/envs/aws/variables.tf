variable "project"    { type = string }
variable "env"        { type = string }
variable "aws_region" { type = string }
variable "admin_username" { type = string, default = "ec2-user" }
variable "ssh_public_key" { type = string, default = "" }
