module "gateway" {
  source                          = "./gateway"
  project_name                    = var.project_name
  env                             = var.env
  aws_api_gateway_integration_ids = module.lambdas.aws_api_gateway_integration_ids
  aws_api_gateway_resource_ids    = module.lambdas.aws_api_gateway_resource_ids
}

module "lambdas" {
  source                                = "./lambdas"
  project_name                          = var.project_name
  env                                   = var.env
  s3_images_id                          = var.s3_images_id
  dynamodb_requests_table_name          = var.dynamodb_requests_table_name
  api_gateway_execution_arn             = module.gateway.api_gateway_execution_arn
  api_gateway_rest_api_id               = module.gateway.api_gateway_rest_api_id
  api_gateway_rest_api_root_resource_id = module.gateway.api_gateway_rest_api_root_resource_id
  api_gateway_authorizer_id             = module.gateway.api_gateway_authorizer_id
}

module "beanstalk" {
  source       = "./beanstalk"
  project_name = var.project_name
  env          = var.env
}

output "iam_role_names_require_s3_access" {
  value = module.lambdas.iam_role_names_require_s3_access
}

output "iam_role_names_require_dynamodb_access" {
  value = concat(module.lambdas.iam_role_names_require_dynamodb_access, [module.beanstalk.ebs_iam_role_name])
}
