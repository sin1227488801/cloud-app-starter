variable "project"        { type = string }
variable "vpc_id"         { type = string }
variable "subnet_id"      { type = string }
variable "admin_username" { type = string, default = "ec2-user" }
variable "ssh_public_key" { type = string, default = "" }

resource "aws_security_group" "sg" {
  name   = "${var.project}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-sg" }
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.project}-kp"
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.kp.key_name

  tags = {
    Name    = "${var.project}-ec2"
    project = var.project
  }
}

output "public_ip" { value = aws_instance.ec2.public_ip }
output "ssh_user"  { value = var.admin_username }
