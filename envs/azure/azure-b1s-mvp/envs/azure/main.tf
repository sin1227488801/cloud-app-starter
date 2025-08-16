module "network" {
  source   = "../../modules/network/azure"
  project  = var.project
  location = var.azure_location
}

module "compute" {
  source         = "../../modules/compute/azure"
  project        = var.project
  location       = module.network.location
  rg_name        = module.network.rg_name
  subnet_id      = module.network.subnet_id
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
}
