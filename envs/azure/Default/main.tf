module "network" {
  source   = "../../modules/network/azure"
  project  = var.project
  location = var.azure_location
}

module "compute" {
  source    = "../../modules/compute/azure"
  project   = var.project
  location  = var.azure_location
  subnet_id = module.network.subnet_id
}
