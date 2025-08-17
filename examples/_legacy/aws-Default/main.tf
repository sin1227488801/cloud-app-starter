module "network" {
  source  = "../../modules/network/aws"
  project = var.project
}

module "compute" {
  source     = "../../modules/compute/aws"
  project    = var.project
  subnet_ids = module.network.subnet_ids
}
