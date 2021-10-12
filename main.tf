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

module "backend" {
  source         = "./backend"
  project_name   = var.project_name
  env            = var.env
  certificate_id = module.certificate.certificate_id
}

module "certificate" {
  source = "./certificate"
  domain = var.domain
  env    = var.env
}

module "domain" {
  source                              = "./domain"
  domain                              = var.domain
  env                                 = var.env
  website_host_ip                     = var.website_host_ip
  api_cname                           = module.backend.ebs_cname
  certificate_validation_record_name  = module.certificate.certificate_validation_record_name
  certificate_validation_record_type  = module.certificate.certificate_validation_record_type
  certificate_validation_record_value = module.certificate.certificate_validation_record_value
}

module "graphql" {
  source                    = "./graphql"
  project_name              = "${var.project_name}-${var.env}"
  dynamo_db_cars_table_name = module.backend.dynamo_db_cars_table_name
  dynamo_db_cars_table_arn  = module.backend.dynamo_db_cars_table_arn
}