variable "project" {
  type = string
}

resource "aws_vpc" "this" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-app" }
}

output "subnet_ids" { value = [aws_subnet.app.id] }
