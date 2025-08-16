module "network" {
  source  = "../../modules/network/aws"
  project = var.project
}

module "compute" {
  source         = "../../modules/compute/aws"
  project        = var.project
  vpc_id         = module.network.vpc_id
  subnet_id      = module.network.public_subnet_id
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
}
