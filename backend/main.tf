
module "api" {
  source                       = "./api"
  project_name                 = var.project_name
  env                          = var.env
  s3_images_id                 = module.s3.s3_images_id
  dynamodb_requests_table_name = module.dynamodb.dynamodb_requests_table_name
  certificate_id               = var.certificate_id
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

output "dynamo_db_cars_table_name" {
  value = module.dynamodb.dynamo_db_cars_table_name
}

output "dynamo_db_cars_table_arn" {
  value = module.dynamodb.dynamo_db_cars_table_arn
}

output "ebs_cname" {
  value = module.api.ebs_cname
}
