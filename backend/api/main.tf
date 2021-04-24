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
  api_gateway_execution_arn             = module.gateway.api_gateway_execution_arn
  api_gateway_rest_api_id               = module.gateway.api_gateway_rest_api_id
  api_gateway_rest_api_root_resource_id = module.gateway.api_gateway_rest_api_root_resource_id
  api_gateway_authorizer_id             = module.gateway.api_gateway_authorizer_id
}

output "iam_role_names_require_s3_access" {
  value = module.lambdas.iam_role_names_require_s3_access
}

output "iam_role_names_require_dynamodb_access" {
  value = module.lambdas.iam_role_names_require_dynamodb_access
}