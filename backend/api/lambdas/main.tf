module "cars_get" {
  source    = "./template"
  operation = "get"

  resource                  = aws_api_gateway_resource.cars.path_part
  project_name              = var.project_name
  env                       = var.env
  api_gateway_execution_arn = var.api_gateway_execution_arn
  api_gateway_authorizer_id = var.api_gateway_authorizer_id
  api_gateway_rest_api_id   = var.api_gateway_rest_api_id
  api_gateway_resource_id   = aws_api_gateway_resource.cars.id
  s3_images_id              = var.s3_images_id
}

module "requests_get" {
  source    = "./template"
  operation = "get"

  resource                     = aws_api_gateway_resource.requests.path_part
  project_name                 = var.project_name
  env                          = var.env
  api_gateway_execution_arn    = var.api_gateway_execution_arn
  api_gateway_authorizer_id    = var.api_gateway_authorizer_id
  api_gateway_rest_api_id      = var.api_gateway_rest_api_id
  api_gateway_resource_id      = aws_api_gateway_resource.requests.id
  dynamodb_requests_table_name = var.dynamodb_requests_table_name
}

resource "aws_api_gateway_resource" "cars" {
  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = var.api_gateway_rest_api_root_resource_id
  path_part   = "cars"
}

resource "aws_api_gateway_resource" "requests" {
  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = var.api_gateway_rest_api_root_resource_id
  path_part   = "requests"
}

output "iam_role_names_require_s3_access" {
  value = [module.cars_get.lambda_iam_role_name]
}

output "iam_role_names_require_dynamodb_access" {
  value = [module.cars_get.lambda_iam_role_name]
}

output "aws_api_gateway_integration_ids" {
  value = [module.cars_get.aws_api_gateway_integration_id]
}

output "aws_api_gateway_resource_ids" {
  value = [aws_api_gateway_resource.cars.id]
}