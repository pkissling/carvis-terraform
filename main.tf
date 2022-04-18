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
  source             = "./backend"
  project_name       = var.project_name
  env                = var.env
  certificate_id     = module.certificate.certificate_id
  auth_client_id     = var.auth_client_id
  auth_client_secret = var.auth_client_secret
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
  website_cname                       = var.website_cnames[var.env]
  api_cname                           = module.backend.ebs_cname
  certificate_validation_record_name  = module.certificate.certificate_validation_record_name
  certificate_validation_record_type  = module.certificate.certificate_validation_record_type
  certificate_validation_record_value = module.certificate.certificate_validation_record_value
  mail_domain_validation_dkim_tokens  = module.mail.mail_domain_validation_dkim_tokens
}

module "mail" {
  source            = "./mail"
  project_name      = var.project_name
  env               = var.env
  domain            = var.domain
  aws_account_id    = var.aws_account_id
  to_mail           = var.to_mail
  ebs_iam_role_name = module.backend.ebs_iam_role_name
}
