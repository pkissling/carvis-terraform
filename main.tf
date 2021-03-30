provider "aws" {
  region = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials.carvis"
}

terraform {
    backend "s3" {
      bucket = "carvis-state"
      key = "app-state"
      region = "eu-west-1"
      shared_credentials_file = "~/.aws/credentials.carvis"
    }
}

module "graphql" {
  source = "./graphql"
  project_name = lookup(var.project_name, var.env)
}

module "images" {
  source = "./images"
  project_name = lookup(var.project_name, var.env)
}

