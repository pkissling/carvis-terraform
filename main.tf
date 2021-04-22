provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials.carvis"
}

terraform {
  backend "s3" {
    bucket                  = "carvis-state"
    key                     = "app-state"
    region                  = "eu-west-1"
    shared_credentials_file = "~/.aws/credentials.carvis"
  }
}

module "graphql" {
  source       = "./graphql"
  project_name = "${var.project_name}-${var.env}"
}

module "backend" {
  source       = "./backend"
  project_name = var.project_name
  env          = var.env
}

