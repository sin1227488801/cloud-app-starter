terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.60" }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_state_bucket" {
  type = string
}

variable "aws_state_dynamodb" {
  type = string
}

variable "aws_state_key" {
  type = string
}
