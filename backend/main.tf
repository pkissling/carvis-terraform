
module "api" {
  source       = "./api"
  project_name = var.project_name
  env          = var.env
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
