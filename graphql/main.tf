resource "aws_appsync_graphql_api" "this" {
  name                = "${var.project_name}-appsync"
  schema              = file("schema.graphql")
  authentication_type = "OPENID_CONNECT"

  openid_connect_config {
    issuer = "https://blumenerd.eu.auth0.com"
  }
}

resource "aws_appsync_datasource" "dynamodb" {
  api_id           = aws_appsync_graphql_api.this.id
  name             = "dynamodb"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.dynamodb.arn

  dynamodb_config {
    table_name = aws_dynamodb_table.cars.name
  }
}

resource "aws_dynamodb_table" "cars" {
  name           = "${var.project_name}-appsync_cars"
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

resource "aws_iam_role" "dynamodb" {
  name               = "${var.project_name}-appsync-dynamodb"
  assume_role_policy = data.aws_iam_policy_document.dynamodb_assume_role.json
}

data "aws_iam_policy_document" "dynamodb_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "dynamodb" {
  name = "${var.project_name}-appsync_dynamodb"
  role = aws_iam_role.dynamodb.id

  policy = data.aws_iam_policy_document.dynamodb.json
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      aws_dynamodb_table.cars.arn
    ]
  }
}

resource "aws_appsync_resolver" "query_getcar" {
  api_id      = aws_appsync_graphql_api.this.id
  field       = "getCar"
  type        = "Query"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("vtl-templates/Query.getCar.request.vtl")
  response_template = "$util.toJson($context.result)"
}

resource "aws_appsync_resolver" "query_listcars" {
  api_id      = aws_appsync_graphql_api.this.id
  field       = "listCars"
  type        = "Query"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("vtl-templates/Query.listCars.request.vtl")
  response_template = "$util.toJson($context.result)"
}

resource "aws_appsync_resolver" "mutation_createcar" {
  api_id      = aws_appsync_graphql_api.this.id
  field       = "createCar"
  type        = "Mutation"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("vtl-templates/Mutation.createCar.request.vtl")
  response_template = "$util.toJson($context.result)"
}

resource "aws_appsync_resolver" "mutation_deleteCar" {
  api_id      = aws_appsync_graphql_api.this.id
  field       = "deleteCar"
  type        = "Mutation"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("vtl-templates/Mutation.deleteCar.request.vtl")
  response_template = "$util.toJson($context.result)"
}

resource "aws_appsync_resolver" "mutation_updatecar" {
  api_id      = aws_appsync_graphql_api.this.id
  field       = "updateCar"
  type        = "Mutation"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template  = file("vtl-templates/Mutation.updateCar.request.vtl")
  response_template = "$util.toJson($context.result)"
}
