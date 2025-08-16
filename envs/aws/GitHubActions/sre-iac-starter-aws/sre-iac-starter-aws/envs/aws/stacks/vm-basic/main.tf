# --- Data sources for defaults (if not provided) ---
# Try to use default VPC/subnet if vpc_id/subnet_id are empty.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Ubuntu 24.04 LTS (owner Canonical)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  selected_vpc_id    = length(var.vpc_id)    > 0 ? var.vpc_id    : data.aws_vpc.default.id
  selected_subnet_id = length(var.subnet_id) > 0 ? var.subnet_id : data.aws_subnets.default.ids[0]
}

module "vm" {
  source        = "../../modules/ec2-docker-vm"
  name          = "sre-docker-vm"
  vpc_id        = local.selected_vpc_id
  subnet_id     = local.selected_subnet_id
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  ssh_cidrs     = var.ssh_cidrs
  tags          = { Project = "sre-iac-starter", Env = "dev" }
}
