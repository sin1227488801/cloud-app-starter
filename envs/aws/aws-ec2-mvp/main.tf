terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" }
  }

  # TODO Phase2: Enable remote state
  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source  = "../../../../modules/network/aws"
  project = var.project
}

module "compute" {
  source     = "../../../../modules/compute/aws"
  project    = var.project
  subnet_ids = module.network.subnet_ids
}
