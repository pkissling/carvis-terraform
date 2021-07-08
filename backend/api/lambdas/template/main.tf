resource "aws_lambda_function" "this" {
  image_uri     = "${aws_ecr_repository.this.repository_url}:${var.env}"
  function_name = "${var.project_name}-${var.env}_${var.resource}-${var.operation}"
  role          = aws_iam_role.this.arn
  package_type  = "Image"

  environment {
    variables = {
      S3_BUCKET                    = var.s3_images_id
      DYNAMODB_REQUESTS_TABLE_NAME = var.dynamodb_requests_table_name
      AUTHORITY                    = "https://carvis.eu.auth0.com/"
    }
  }
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.api_gateway_rest_api_id
  resource_id   = var.api_gateway_resource_id
  http_method   = upper(var.operation)
  authorization = "NONE"
  # authorizer_id = var.api_gateway_authorizer_id
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = var.api_gateway_rest_api_id
  resource_id = var.api_gateway_resource_id
  http_method = aws_api_gateway_method.this.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

output "aws_api_gateway_integration_id" {
  value = aws_api_gateway_integration.this.id
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-${var.env}-lambda_${var.resource}_${var.operation}"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.resource}-${var.operation}"
  image_tag_mutability = "MUTABLE"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name   = "${var.project_name}-${var.env}_${var.resource}-${var.operation}-lambda_logging"
  path   = "/"
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

output "lambda_iam_role_name" {
  value = aws_iam_role.this.name
}
