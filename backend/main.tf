
module "api" {
  source             = "./api"
  project_name       = var.project_name
  env                = var.env
  certificate_id     = var.certificate_id
  auth_client_id     = var.auth_client_id
  auth_client_secret = var.auth_client_secret
}

module "ci" {
  source       = "./ci"
  project_name = var.project_name
}

module "dynamodb" {
  source                                 = "./dynamodb"
  project_name                           = var.project_name
  env                                    = var.env
  iam_role_names_require_dynamodb_access = module.api.iam_role_names_require_dynamodb_access
}

module "s3" {
  source                           = "./s3"
  project_name                     = var.project_name
  env                              = var.env
  iam_role_names_require_s3_access = module.api.iam_role_names_require_s3_access
}

module "queues" {
  source            = "./queues"
  project_name      = var.project_name
  env               = var.env
  ebs_iam_role_name = module.api.ebs_iam_role_name
}

output "ebs_cname" {
  value = module.api.ebs_cname
}

output "ebs_iam_role_name" {
  value = module.api.ebs_iam_role_name
}
