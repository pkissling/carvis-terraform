resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-${var.env}"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

output "api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

resource "aws_api_gateway_deployment" "v1" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "v1"

  triggers = {
    redeployment = sha1(join("", [
      sha1(file("./backend/api/gateway/main.tf")),
      sha1(file("./backend/api/lambdas/main.tf"))
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "options" {
  count         = length(var.aws_api_gateway_resource_ids)
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = var.aws_api_gateway_resource_ids[count.index]
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options" {
  count       = length(var.aws_api_gateway_resource_ids)
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.aws_api_gateway_resource_ids[count.index]
  http_method = aws_api_gateway_method.options[count.index].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  count       = length(var.aws_api_gateway_resource_ids)
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.aws_api_gateway_resource_ids[count.index]
  http_method = aws_api_gateway_method.options[count.index].http_method
  status_code = aws_api_gateway_method_response.options[count.index].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration" "options" {
  count = length(var.aws_api_gateway_resource_ids)

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.aws_api_gateway_resource_ids[count.index]
  http_method = aws_api_gateway_method.options[count.index].http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

output "api_gateway_authorizer_id" {
  value = aws_api_gateway_authorizer.this.id
}


resource "aws_api_gateway_authorizer" "this" {
  authorizer_credentials           = module.authorizer.lambda_role_arn
  authorizer_uri                   = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/${module.authorizer.lambda_arn}/invocations"
  name                             = "auth0"
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  authorizer_result_ttl_in_seconds = 0
}

module "authorizer" {
  source                  = "jdpx/auth0-authorizer/aws"
  version                 = "0.1.1"
  authorizer_audience     = "ukQnXHJoRrZwGf85Uh4Jpk8V932GsfKt"
  authorizer_jwks_uri     = "https://carvis.eu.auth0.com/.well-known/jwks.json"
  authorizer_token_issuer = "https://carvis.eu.auth0.com/"
  lambda_function_name    = "${var.project_name}-${var.env}-auth0_authorizer"
  lambda_role_name        = "${var.project_name}-${var.env}-lambda_auth0_authorizer"
}

output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}
