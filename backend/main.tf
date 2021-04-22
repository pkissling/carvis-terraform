
module "api" {
  source       = "./api"
  project_name = var.project_name
  env          = var.env
}

module "ci" {
  source       = "./ci"
  project_name = var.project_name
}

module "s3" {
  source                      = "./s3"
  project_name                = var.project_name
  env                         = var.env
  iam_roles_require_s3_access = module.api.iam_roles_require_s3_access
}
