resource "aws_dynamodb_table" "cars" {
  name           = "${var.env}-${var.project_name}-cars"
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
  name           = "${var.env}-${var.project_name}-requests"
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

resource "aws_dynamodb_table" "new-users" {
  name           = "${var.env}-${var.project_name}-new-users"
  hash_key       = "userId"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "userId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.project_name}-${var.env}-read_write_dynamodb"
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      aws_dynamodb_table.cars.arn,
      aws_dynamodb_table.new-users.arn,
      aws_dynamodb_table.requests.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.iam_role_names_require_dynamodb_access)
  role       = var.iam_role_names_require_dynamodb_access[count.index]
  policy_arn = aws_iam_policy.this.arn
}
