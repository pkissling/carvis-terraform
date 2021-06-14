resource "aws_dynamodb_table" "cars" {
  name           = "${var.project_name}-${var.env}-cars"
  hash_key       = "id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_dynamodb_table" "requests" {
  name           = "${var.project_name}-${var.env}-requests"
  hash_key       = "id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.project_name}-${var.env}-access_dynamodb"
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      aws_dynamodb_table.cars.arn,
      aws_dynamodb_table.requests.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.iam_role_names_require_dynamodb_access)
  role       = var.iam_role_names_require_dynamodb_access[count.index]
  policy_arn = aws_iam_policy.this.arn
}

output "dynamo_db_cars_table_name" {
  value = aws_dynamodb_table.cars.name
}

output "dynamo_db_cars_table_arn" {
  value = aws_dynamodb_table.cars.arn
}

output "dynamodb_requests_table_name" {
  value = aws_dynamodb_table.requests.name
}